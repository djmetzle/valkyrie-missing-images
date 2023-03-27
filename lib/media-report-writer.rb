require 'securerandom'

SCREENCAP_FOLDER = 'screenshots'

class MediaReportWriter
  def initialize(medias_with_missing_images)
    @medias = medias_with_missing_images
  end

  def generate_report()
    write_index()
    @medias.each do |media|
      write_media(media)
    end
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
      media_file.write h1 + links
    end
  end
end
