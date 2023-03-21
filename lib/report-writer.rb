require 'securerandom'

SCREENCAP_FOLDER = 'screenshots'

class ReportWriter
  def initialize(posts_with_missing_images)
    @posts = posts_with_missing_images
  end

  def generate_report()
    write_index()
    @posts.each do |post|
      write_post(post)
    end
  end

  def write_index()
    File.open("report/report.md", "w") do |index_file|
      h1 = "\# Valkyrie Missing Images Report\n\n"
      post_list = ""
      @posts.each do |post|
        post_list += "- #{post.post.id} - #{post.post.title}\n"
      end
      index_file.write h1 + post_list + "\n"
    end
  end

  def write_post(post)
    File.open("report/post-#{post.post.id}.md", "w") do |post_file|
      h1 = "\# Post #{post.post.id} - [#{post.post.title}](#{post.post.link})\n\n"
      missing_images = post.missing.broken_links.map do |broken_link|
        "- #{broken_link}\n"
      end.join("")
      screencap_link = "![screencap](#{SCREENCAP_FOLDER}/#{post.missing.screenshot})\n"
      post_file.write h1 + missing_images + "\n" + screencap_link
    end
  end
end
