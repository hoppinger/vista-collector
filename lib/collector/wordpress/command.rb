require 'json'

module Collector
  module Wordpress

    class Command < Collector::Command

      attr_accessor :current

      def initialize(current)
        @current = current
        @wp_cli = ENV['WP_CLI'] ? ENV['WP_CLI'] : 'wp'
      end

      def blog_name
        execute("cd #{@current.path} && #{@wp_cli} option get blogname") do |output, error|
          @current.errors << error unless error.nil?
          @current.blog_name = output
        end
      end

      def version
        execute("cd #{@current.path} && #{@wp_cli} core version") do |output, error|
          @current.errors << error unless error.nil?
          @current.version = output
        end
      end

      def plugins
        execute("cd #{@current.path} && #{@wp_cli} plugin list --format=json") do |output, error|
          @current.errors << error unless error.nil?
          @current.plugins = json_parse(output)
        end
      end

    end

  end
end