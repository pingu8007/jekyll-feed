require 'fileutils'

module Jekyll
  class PageWithoutAFile < Page
    def read_yaml(*)
      @data ||= {}
    end
  end

  class JekyllRssFeed < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      @site = site
      @site.config["time"]         = Time.new
      unless feed_exists?
        write
        @site.keep_files ||= []
        @site.keep_files << "feed.xml"
      end
    end

    # Path to feed.xml template file
    def source_path
      File.expand_path "feed.xml", File.dirname(__FILE__)
    end

    # Destination for feed.xml file within the site source directory
    def destination_path
      if @site.respond_to?(:in_dest_dir)
        @site.in_dest_dir("feed.xml")
      else
        Jekyll.sanitized_path(@site.dest, "feed.xml")
      end
    end

    # copy sitemap template from source to destination
    def write
      FileUtils.mkdir_p File.dirname(destination_path)
      File.open(destination_path, 'w') { |f| f.write(sitemap_content) }
    end

    def sitemap_content
      site_map = PageWithoutAFile.new(@site, File.dirname(__FILE__), "", "feed.xml")
      site_map.content = File.read(source_path).gsub(/\s*\n\s*/, "\n").gsub(/\n{%/, "{%")
      site_map.data["layout"] = nil
      site_map.render(Hash.new, @site.site_payload)
      site_map.output
    end

    # Checks if a sitemap already exists in the site source
    def feed_exists?
      if @site.respond_to?(:in_source_dir)
        File.exists? @site.in_source_dir("feed.xml")
      else
        File.exists? Jekyll.sanitized_path(@site.source, "feed.xml")
      end
    end
  end
end
