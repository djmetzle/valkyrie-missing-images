require 'securerandom'

SCREENCAP_FOLDER = 'screenshots'

class MediaReportWriter
  def initialize(medias_with_missing_images)
    @medias = medias_with_missing_images
    @stray_prefixes = build_prefixes()
  end

  def generate_report()
    write_index()
    @medias.each do |media|
      write_media(media)
    end
  end

  def build_prefixes()
    stray_items = File.open("./prefix-scrape.out").readlines.map(&:chomp)
    stray_prefixes = Hash.new
    stray_items.each do |item|
      prefix = prefix_from_item(item)
      stray_prefixes[prefix] ||= []
      stray_prefixes[prefix].push(item)
    end
    return stray_prefixes
  end

  def check_prefixes()
    #pp @stray_prefixes
  end

  def prefix_from_item(item)
      key = item.gsub(/^https:\/\/valkyrie\.cdn\.ifixit\.com\//, "")
      prefix = key.gsub(/\/[^\/]*$/, '')
      return prefix
  end

  def write_index()
    File.open("report/media-report.md", "w") do |index_file|
      h1 = "\# Valkyrie Media Report\n\n"
      media_list = ""
      @medias.each do |media|
        media_list += "- #{media.id} - [#{media.title}](media-#{media.id}.md)\n"
      end
      index_file.write h1 + media_list + "\n"
    end
  end

  def write_media(media)
    File.open("report/media-#{media.id}.md", "w") do |media_file|
      h1 = "\# Media #{media.id} - #{media.title}\n\n"
      links = media.urls.map do |link|
        "- ![image](#{link})\n"
      end.join("")
      strays = build_strays(media)
      media_file.write h1 + links + strays
    end
  end

  def build_strays(media)
    prefix = prefix_from_item(media.urls.first)
    if @stray_prefixes.key?(prefix)
      all_stray_urls = @stray_prefixes[prefix]
      strays = all_stray_urls - media.urls
      return "\n## Strays\n" + strays.map { |stray| "- ![stray](#{stray})" }.join("\n")
    end
    return ""
  end
end
