require 'json'
require 'bundler'

module Collector
  module Rails

    class Command < Collector::Command

      attr_accessor :current

      def initialize(current)
        super
        @current = current

        @lockfile = File.exist?("#{@current.path}/Gemfile.lock") ? Bundler::LockfileParser.new(Bundler.read_file("#{@current.path}/Gemfile.lock")) : false
      end

      def blog_name
        #execute("cd #{@current.path} && #{@wp_cli} option get blogname") do |output, error|
        #  @current.errors << error unless error.nil?
        #  @current.blog_name = output
        #end
      end

      def version
        unless @lockfile
          @current.version = ''
          return
        end

        rails = @lockfile.specs.select{|g| g.name == "rails"}.first;

        if rails
          @current.version = rails.version.version
        end

      end

      def plugins
        unless @lockfile
          @current.plugins = []
          return
        end

        @current.plugins = @lockfile.specs.map do |g|
          {
            name: g.name,
            status: :active,
            update: :none,
            version: g.version.version
          }
        end
      end

      def meta
        execute("cd #{@current.path} && cat .ruby-version") do |output, error|
          if error.empty?
            @current.meta[:ruby_version] = output
          end
        end
      end

    end

  end
end
