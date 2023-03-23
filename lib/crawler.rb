require 'nokogiri'
require 'open-uri'

# Fetch and parse HTML document
#

class Crawler
  def initialize()
  end

  def crawl_for_broken_image_links(link)
    doc = fetch_document(link)
    image_elements = doc.css('img') 
    links = image_elements.map { |image| find_links(image) }.flatten.compact
    cdn_links = cdn_only_links(links)
    broken_links = find_broken(cdn_links)
    return broken_links
  end

  def fetch_document(link)
    doc = Nokogiri::HTML(URI.open(link))
    return doc
  end

  def cdn_only_links(links)
    return links.select do |link|
      link.match?(/^https:\/\/valkyrie\.cdn\.ifixit\.com/)
    end
  end

  def find_links(element)
    links = []
    src = element.attr('src')
    links.push(src)
    srcset_string = element.attr('srcset')
    unless srcset_string.nil? || srcset_string.empty?
      links.push(*parse_srcset_string(srcset_string))
    end
    return links
  end

  def parse_srcset_string(string)
    image_defs = string.split(",").map(&:strip)
    return image_defs.map do |srcset_string|
      srcset_string.gsub(/ \d+w$/, '')
    end
  end

  def find_broken(links)
    return links.select { |link| broken_link?(link) }
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
end
