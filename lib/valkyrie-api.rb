require 'net/http'
require 'uri'
require 'json'

API_BASE = 'https://54.71.223.11/wp-json/wp/v2'
POSTS_ENDPOINT = API_BASE + '/posts'
PAGES_ENDPOINT = API_BASE + '/pages'
MEDIA_ENDPOINT = API_BASE + '/media'

PER_PAGE = 100

POST_FIELDS = 'id,title,link'
PAGE_FIELDS = 'id,title,link'

PostLink = Struct.new('PostLink', :id, :link, :title)
PageLink = Struct.new('PageLink', :id, :link, :title)
MediaLink = Struct.new('MediaLink', :id, :link, :title)

class ValkyrieAPI
  def initialize()
    if basic_auth().nil? || basic_auth() == ""
      raise "Please provide VALKYRIE_BASIC_AUTH as ENV variable"
    end
  end

  def basic_auth()
    ENV['VALKYRIE_BASIC_AUTH']
  end

  def fetch_post_list()
    i = 1
    all_posts = []
    while true
       posts = get_page(i, POSTS_ENDPOINT)
       i += 1
       break if posts.nil?
       STDERR.puts "Fetched #{posts.size} posts from API"
       all_posts.push(*posts)
    end
    return all_posts.map { |post|
        to_struct(post)
      }.select { |post|
        is_valkyrie_post?(post.link)
      }
  end

  def fetch_page_list()
    i = 1
    all_pages = []
    while true
       pages = get_page(i, PAGES_ENDPOINT)
       i += 1
       break if pages.nil?
       STDERR.puts "Fetched #{pages.size} pages from API"
       all_pages.push(*pages)
    end
    return all_pages.map { |page|
        to_page_struct(page)
      }

  end

  def fetch_media_list()
    i = 1
    all_medias = []
    while true
       medias = get_page(i, MEDIA_ENDPOINT)
       i += 1
       break if medias.nil?
       STDERR.puts "Fetched #{medias.size} medias from API"
       all_medias.push(*medias)
    end
    return all_medias.map { |media|
        to_media_struct(media)
      }

  end

  def get_page(n, endpoint)
     params = {
        :page => n,
        :per_page => PER_PAGE,
        :_fields => POST_FIELDS,
     }
     return fetch_endpoint(endpoint, params)
  end

  def fetch_endpoint(endpoint, params)
     uri = URI.parse(endpoint)
     uri.query = URI.encode_www_form(params)
     request = Net::HTTP::Get.new(uri)
     request["Authorization"] = basic_auth()
     request["Host"] = 'valkyrie.ifixit.com'

     req_options = {
          :use_ssl => true,
          :verify_mode => OpenSSL::SSL::VERIFY_NONE,
     }

     response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
     end

     if response.code != "200"
        return nil
     end

     return JSON.parse(response.body)
  end

  def to_struct(post)
    post_struct = PostLink.new(post["id"], post["link"], post["title"]["rendered"])
    return post_struct
  end

  def to_page_struct(page)
    page_struct = PageLink.new(page["id"], page["link"], page["title"]["rendered"])
    return page_struct
  end

  def to_media_struct(media)
    media_struct = MediaLink.new(media["id"], media["link"], media["title"]["rendered"])
    return media_struct
  end

  def is_valkyrie_post?(link)
    good_link = link.match?(/^https:\/\/www\.ifixit\.com\/News/)
    STDERR.puts "Non-wordpress link found: #{link}" unless good_link
    return good_link
  end
end
