#!/usr/bin/ruby -w

require "selenium-webdriver"

require 'net/http'
require 'uri'

require 'securerandom'

ImageElement = Struct.new('ImageElement', :element, :links, :broken_links)

BrokenImages = Struct.new('BrokenImages', :url, :broken_links, :screenshot)

SCREENCAP_FOLDER_PATH = './report/screenshots'

class MissingImages
  def initialize()
    options = Selenium::WebDriver::Firefox::Options.new(args: [])
  #  options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    @driver = Selenium::WebDriver.for(:firefox, options: options)
    @driver.manage.timeouts.implicit_wait = 10
  end

  def find_missing_images(url)
    STDERR.puts "Crawling for broken images at: #{url}"
    @driver.navigate.to(url)

    elements_with_broken_links = find_broken_link_elements()

    if elements_with_broken_links.empty?
      @driver.close
      return nil
    end

    highlight_broken_images(elements_with_broken_links)

    screenshot_filename = "#{SecureRandom.uuid}.png"
    screenshot_path = SCREENCAP_FOLDER_PATH + "/#{screenshot_filename}"
    @driver.save_screenshot(screenshot_path, full_page: true)

    @driver.close

    broken_links = elements_with_broken_links.map { |el| el.broken_links }.flatten

    return BrokenImages.new(url, broken_links, screenshot_filename)
  end

  def find_broken_link_elements()
    image_elements = find_all_images()

    return [] if image_elements.nil?

    image_elements.each do |element|
      find_broken_links(element)
    end

    elements_with_broken_links = image_elements.select do |element|
      element.broken_links.size.positive?
    end

    return elements_with_broken_links
  end

  def highlight_broken_images(elements)
    elements.each do |element|
      @driver.execute_script("arguments[0].style.border='10px solid red'", element.element)
    end
  end

  def find_all_images()
    wp_content = find_wp_shadow_content()
    return nil if wp_content.nil?
    image_elements = wp_content.find_elements(:tag_name, "img")
    return image_elements.map do |element|
      ImageElement.new(element, find_image_links(element), [])
    end
  end

  def find_broken_links(element)
    broken_links = element.links.select { |link| broken_link?(link) }
    broken_links.each { |link| STDERR.puts "Broken link: #{link}" }
    element.broken_links = broken_links
  end

  def broken_link?(link)
    uri = URI.parse(link)
    request = Net::HTTP::Head.new(uri)
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return response.code != "200"
  end

  def find_image_links(element)
    srcset = parse_srcset_images(element)
    return [element.attribute("src"), srcset].flatten.compact
  end

  def parse_srcset_images(element)
    srcset_string = element.attribute("srcset")
    return [] if srcset_string.empty?
    return parse_srcset_string(srcset_string)
  end

  def parse_srcset_string(string)
    image_defs = string.split(",").map(&:strip)
    return image_defs.map do |srcset_string|
      srcset_string.gsub(/ \d+w$/, '')
    end
  end

  def find_wp_shadow_content()
    begin
      shadow_wrapper_element = @driver.find_element(tag_name: 'shadow-wrapper')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      return nil
    end
    script = 'return arguments[0].shadowRoot.children'
    shadow_children = @driver.execute_script(script, shadow_wrapper_element)
    wp_content = shadow_children[0]

    return wp_content
  end
end
