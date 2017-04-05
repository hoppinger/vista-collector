require 'json'
require 'inifile'

module Collector
  module Symfony

    class Command < Collector::Command

      attr_accessor :current
      attr_accessor :ini

      def initialize(current)
        super
        @current = current
        @ini = IniFile.load(@current.dir + '/deps')
      end

      def blog_name

      end

      def version
        @current.version = @ini['symfony']['version'].gsub('v', '')
      end

      def plugins
        plugins = []
        @ini.each_section do |section|
          plugins << {
            name: section,
            status: :active,
            update: :none,
            version: @ini[section]['version']
          }
        end

        @current.plugins = plugins
      end

    end

  end
end
