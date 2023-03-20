#!/usr/bin/ruby -w

require 'fileutils'

require_relative "./lib/missing-images"

FileUtils.mkdir_p './report/screenshots'

URL = "https://www.ifixit.com/News/31963/samsung-galaxy-note8-teardown-wallpapers"
missing_images = MissingImages.new
missing_images.find_missing_images(URL)

URL2 = "https://www.ifixit.com/News/10111/oneplus-6-teardown"
missing_images = MissingImages.new
missing_images.find_missing_images(URL2)
