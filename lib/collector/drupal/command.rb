require 'json'

module Collector
  module Drupal

    class Command < Collector::Command

      attr_accessor :current

      def initialize(current)
        @current = current
      end

      def blog_name
        @current.blog_name = execute do
          "cd #{@current.path} && drush vista-n"
        end
      end

      def version
        @current.version = execute do
          "cd #{@current.path} && drush vista-cv"
        end
      end

      def plugins
        plugin_info = execute do
          "cd #{@current.path} && drush vista-m"
        end
        @current.plugins = json_parse(plugin_info)
      end

    end

  end
end