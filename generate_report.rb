#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/valkyrie-api"
require_relative "./lib/crawler"

require 'json'

PostWithMissingImages = Struct.new('PostWithMissingImages', :post, :missing)

api = ValkyrieAPI.new
crawler = Crawler.new

post_links = api.fetch_post_list()
puts "Fetched #{post_links.size} posts"

post_links.each do |post|
  broken_links = crawler.crawl_for_broken_image_links(post.link)
  next if broken_links.empty?
  post_with_broken_links = PostWithMissingImages.new(post, broken_links)
  pp post_with_broken_links
end
