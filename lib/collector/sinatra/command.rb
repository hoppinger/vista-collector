require 'json'
require 'bundler'

module Collector
  module Sinatra
    class Command < Collector::Command
      attr_accessor :current

      def initialize(current)
        super
        @current = current

        @lockfile = Bundler::LockfileParser.new(Bundler.read_file("#{@current.path}/Gemfile.lock"));
      end

      def blog_name
        nil
      end

      def version
        sinatra = @lockfile.specs.select { |g| g.name == 'sinatra' }.first

        @current.version = sinatra.version.version if sinatra
      end

      def plugins
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
          @current.meta[:ruby_version] = output if error.empty?
        end
      end
    end
  end
end
