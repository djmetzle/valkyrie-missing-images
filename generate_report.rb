#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/missing-images"
require_relative "./lib/valkyrie-api"
require_relative "./lib/report-writer"

require 'json'

PostWithMissingImages = Struct.new('PostWithMissingImages', :post, :missing)

api = ValkyrieAPI.new

post_links = api.fetch_post_list()

#puts JSON.dump(post_links.map(&:to_h))

FileUtils.mkdir_p './report/screenshots'
FileUtils.mkdir_p './report/posts'

def build_missing(post, missing)
  return nil if missing.broken_links.empty?
  return PostWithMissingImages.new(post, missing)
end

posts_with_missing_images = post_links.map do |post|
  missing_images = MissingImages.new
  missing = missing_images.find_missing_images(post.link)
  build_missing(post, missing)
end.compact

writer = ReportWriter.new(posts_with_missing_images)
writer.generate_report()
