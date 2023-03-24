#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/valkyrie-api"
require_relative "./lib/crawler"
require_relative "./lib/report-writer"

require 'json'

PostWithMissingImages = Struct.new('PostWithMissingImages', :post, :missing)

api = ValkyrieAPI.new
crawler = Crawler.new

post_links = api.fetch_post_list()
puts "Fetched #{post_links.size} posts"

posts_with_broken_links = []
all_broken_links = []

post_links.each do |post|
  broken_links = crawler.crawl_for_broken_image_links(post.link)
  next if broken_links.empty?
  post_with_broken_links = PostWithMissingImages.new(post, broken_links)
  posts_with_broken_links.push(post_with_broken_links)
  all_broken_links.push(*broken_links)
end

writer = ReportWriter.new(posts_with_broken_links)
writer.generate_report()
