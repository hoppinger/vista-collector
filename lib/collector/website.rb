module Collector
  class Website

    attr_accessor :vhost, :dir, :blog_name, :version, :plugins,
      :type, :errors

    def initialize(vhost, dir)
      @vhost = vhost
      @dir = dir
    end

    def path
      File.join(@vhost, @dir)
    end

    def project_name
      if File.split(@dir).include?(".")
        File.split(@dir).last
      else
        File.split(@dir).first
      end
    end

    def has_update(newest_ver)
      newest_ver != version
    end

    # Project contains errors, that will have leaked into the parsed results
    # like the @blog_name. We copy these errors to the @errors instance variable
    # to be collected along
    def nullify
      @errors = @blog_name
      @blog_name = nil
      @version = nil
      @plugins = nil
    end

    def has_errors
      if plugins.nil? || plugins.empty?
        nullify
        true
      else
        false
      end
    end

    # One to one mapping for a Rails model
    def to_hash(newest_ver)
      {
        website: {
          name: project_name,
          version: version,
          blog_name: blog_name,
          has_update: has_update(newest_ver),
          has_errors: has_errors,
          website_errors: errors,
          plugins: plugins,
          cms_type: type,
        }
      }
    end

  end
end