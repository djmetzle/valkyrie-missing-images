#!/usr/bin/env ruby
require 'pathname'
require 'uri'

index = {}

Pathname.glob("report/media-*.md").each do |path|
  next if path.basename.to_s == "media-report.md"

  entry = path.read
  lines = entry.lines.filter { |l| l =~ /^-/ }
  lines.each do |line|
    primary = line[11..-3]
    # primary_match = line[11..-3]#.match(/^(.*?)(-scaled)?\.(\w+)$/)
    # p lines[0]
    # p primary_match
    # primary = "#{primary_match[1]}.#{primary_match[3]}"
    puts "#{path}: #{primary}"
    uri = URI(primary)
    uri_path = Pathname.new(uri.path)
    index[uri_path.basename.to_s] = path
  end
end

Pathname.glob("report/post-*.md").each do |path|
  entry = path.read
  print entry
  # lines = entry.lines.filter { |l| l =~ /^-/ }
  updated = entry.lines.map do |line|
    if line =~ /^-/ and not line =~ /\[media item\]/
      uri = URI(line[2..-2])
      uri_path = Pathname.new(uri.path)
      p uri_path.basename
      match = uri_path.basename.to_s.match(/^(.*?)(-\d+x\d+)?\.(\w+)$/)
      basename = "#{match[1]}.#{match[3]}"
      media_item = index[basename]
      unless media_item
        media_item = index[uri_path.basename.to_s]
        unless media_item
          puts "missing"
          p basename
          exit 1
        end
      end
      "#{line.strip} [media item](#{media_item.basename.to_s})"
    else
      line.strip
    end
  end
  updated_text = updated.join("\n")
  puts "~~~"
  print updated_text
  path.write updated_text
end

puts "---"
