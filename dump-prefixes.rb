#!/usr/bin/ruby -w

require 'fileutils'

$broken_links = File.open("./broken-links.lst").readlines.map(&:chomp)

prefixes = $broken_links.map do |link|
  link.sub(/^https:\/\/valkyrie\.cdn\.ifixit\.com\//, '').gsub(/^(media\/[\d]{4}\/[\d]{2}\/[\d]+).*/, '\1')
end

prefixes.sort.uniq.each { |p| puts p }
