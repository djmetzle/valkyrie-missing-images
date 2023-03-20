require 'net/http'
require 'uri'
require 'json'

ENDPOINT = 'https://54.71.223.11/wp-json/wp/v2/posts'

PER_PAGE = 100

POST_FIELDS = 'id,title,link'

PostLink = Struct.new('PostLink', :id, :link, :title)

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
       posts = get_page(i)
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

  def get_page(n)
     uri = URI.parse(ENDPOINT)
     params = {
        :page => n,
        :per_page => PER_PAGE,
        :_fields => POST_FIELDS,
     }
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

  def is_valkyrie_post?(link)
    good_link = link.match?(/^https:\/\/www\.ifixit\.com\/News/)
    STDERR.puts "Non-wordpress link found: #{link}" unless good_link
    return good_link
  end
end
