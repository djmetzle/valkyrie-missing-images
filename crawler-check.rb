#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/valkyrie-api"
require_relative "./lib/crawler"
require_relative "./lib/missing-images"

require 'json'

#post = PostLink.new(73288,'https://www.ifixit.com/News/73288/m2-macbook-pro-screen-swaps-are-kinda-haunted','Foo Bar Baz')
post = PostLink.new(73288,'https://www.ifixit.com/News/73288/m2-macbook-pro-screen-swaps-are-kinda-haunted','Foo Bar Baz')

crawler = Crawler.new

pp crawler.crawl_for_broken_image_links(post.link)
