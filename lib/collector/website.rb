module Collector
  class Website

    attr_accessor :vhost, :dir, :blog_name, :version, :plugins,
      :type, :errors

    def initialize(vhost, dir)
      @vhost = vhost
      @dir = dir
      @errors = []
    end

    def path
      @dir
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

    # Project contains errors. We nullify the fields.
    def nullify
      @blog_name = nil
      @version = nil
      @plugins = nil
    end

    def has_errors
      @errors.any? do |error|
        error.include?("Fatal error") || error.include?("Exception")
      end || @plugins.nil?
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