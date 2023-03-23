#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/missing-images"
require_relative "./lib/valkyrie-api"
require_relative "./lib/report-writer"

require 'json'

PostWithMissingImages = Struct.new('PostWithMissingImages', :post, :missing)

api = ValkyrieAPI.new

page_links = api.fetch_page_list()

FileUtils.mkdir_p './report/screenshots'

def build_missing(page, missing)
  return nil if missing.broken_links.empty?
  return PostWithMissingImages.new(post, missing)
end

pages_with_missing_images = page_links.map do |page|
  begin
    missing_images = MissingImages.new
    url_to_crawl = 'https://www.ifixit.com' + page.link.gsub(/^\/Page/,'')
    missing = missing_images.find_missing_images(url_to_crawl)
    next if missing.nil?
    build_missing(page, missing)
  #rescue Exception
  #  nil
  end
end.compact

#writer = ReportWriter.new(posts_with_missing_images)
#writer.generate_report()
