require 'json'
require 'popen4'
require 'highline/import'

module Collector
  class Command
    attr_accessor :current

    def initialize(current)
      @current = current
    end

    def blog_name
      @current.blog_name = execute do
        "cd #{current.dir} && wp option get blogname"
      end
    end

    def version
      @current.version = execute do
        "#cd {current.dir} && wp core version"
      end
    end

    def plugins
      plugin_info = execute do
        "cd #{current.dir} && wp plugin list --format=json"
      end
      @current.plugins = json_parse(plugin_info)
    end

    private

    def execute(&block)
      output = nil
      error  = nil
      cmd = block.call

      status = POpen4.popen4(cmd) do |stdout, stderr|
        output = stdout.read.strip
        error  = stderr.read.strip
      end
      output
    end

    def json_parse(info)
      begin
        # WP_CLI uses update, but that method is reserved by ActiveRecord
        output.gsub!('"update"', '"has_update"')
        # WP_CLI uses "none", but we use Booleans
        output.gsub!('"none"', 'false')
        # WP_CLI uses "available", but we use Booleans
        output.gsub!('"available"', 'true')
        output = JSON.parse(output)
      rescue JSON::ParserError
        say("<%= color('[stderr:]', :red) %> Error parsing json in #{current.dir}")
        output = nil
      end
    end

  end
end