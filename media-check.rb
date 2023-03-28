#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/valkyrie-api"
require_relative "./lib/media-report-writer"

require 'json'

api = ValkyrieAPI.new

$broken_links = File.open("./broken-links.lst").readlines.map(&:chomp)

def broken?(link)
  return $broken_links.include?(link)
end

media_links = api.fetch_media_list()
puts "Fetched #{media_links.size} media items"

media_with_broken_links = media_links.select do |media|
  media.urls.any? { |url| broken?(url) }
end

puts "Found #{media_with_broken_links.size} media items with broken URLs"

writer = MediaReportWriter.new(media_with_broken_links)
writer.check_prefixes
writer.generate_report()
