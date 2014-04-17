module Collector
  class Website

    attr_accessor :vhost, :dir, :blog_name, :version, :plugins, :type

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

    def has_errors
      plugins.nil? || plugins.empty?
    end

    def to_hash(newest_ver)
      {
        website: {
          name: project_name,
          version: version,
          blog_name: blog_name,
          has_update: has_update(newest_ver),
          has_errors: has_errors,
          plugins: plugins,
          cms_type: type,
        }
      }
    end

  end
end