module Collector
  class Website

    attr_accessor :dir, :blog_name, :version, :plugins

    def initialize(dir)
      @dir = dir
    end

    def has_update(newest_ver)
      newest_ver != version
    end

    def has_errors
      plugins.nil? || plugins.empty?
    end

    def to_hash
      {
        name: blog_name,
        has_update: has_update,
        has_errors: has_errors,
        plugins: plugins,
      }
    end

  end
end