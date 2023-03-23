#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/valkyrie-api"

require 'json'

api = ValkyrieAPI.new

post_links = api.fetch_post_list()
puts "Fetched #{post_links.size} posts"
p post_links.first

#page_links = api.fetch_page_list()
#puts "Fetched #{page_links.size} pages"
#p page_links.first

#media_links = api.fetch_media_list()
#puts "Fetched #{media_links.size} media items"
