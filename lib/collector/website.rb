module Collector
  class Website

    attr_accessor :vhost, :dir, :blog_name, :version, :plugins

    def initialize(vhost, dir)
      @vhost = vhost
      @dir = dir
    end

    def path
      File.join(@vhost, @dir)
    end

    def project_name
      File.split(@dir).first
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
          blog_name: blog_name,
          has_update: has_update(newest_ver),
          has_errors: has_errors,
          plugins: plugins,
        }
      }
    end

  end
end