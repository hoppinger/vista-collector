require 'json'

module Collector
  module Wordpress

    class Command < Collector::Command

      attr_accessor :current

      def initialize(current)
        @current = current
      end

      def blog_name
        @current.blog_name = execute do
          "cd #{@current.path} && wp option get blogname"
        end
      end

      def version
        @current.version = execute do
          "cd #{@current.path} && wp core version"
        end
      end

      def plugins
        plugin_info = execute do
          "cd #{@current.path} && wp plugin list --format=json"
        end
        @current.plugins = json_parse(plugin_info)
      end

    end

  end
end