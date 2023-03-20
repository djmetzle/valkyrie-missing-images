#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/missing-images"
require_relative "./lib/valkyrie-api"

require 'json'

PostWithMissingImages = Struct.new('PostWithMissingImages', :post, :missing)

api = ValkyrieAPI.new

post_links = api.fetch_post_list()

#puts JSON.dump(post_links.map(&:to_h))

FileUtils.mkdir_p './report/screenshots'

def build_missing(post, missing)
  return nil if missing.broken_links.empty?
  return PostWithMissingImages.new(post, missing)
end

# DEBUG `last(2)`
posts_with_missing_images = post_links.last(2).map do |post|
  missing_images = MissingImages.new
  missing = missing_images.find_missing_images(post.link)
  build_missing(post, missing)
end.compact

pp posts_with_missing_images
