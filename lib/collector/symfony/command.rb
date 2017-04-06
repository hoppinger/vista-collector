require 'json'
require 'inifile'

module Collector
  module Symfony

    class Command < Collector::Command

      attr_accessor :current
      def initialize(current)
        super
        @current = current
        @ini_file = @current.dir + '/deps'
        @composer_file = Pathname.new(@current.dir).parent.join('composer.lock')
      end

      def blog_name
        
      end

      def version
        plugins = _plugins
        if plugins.any?
          @current.version = plugins.select { |p| p[:name] == 'symfony' }.first[:version].sub('v', '')
        else
          @current.version = ''
        end
      end

      def plugins
        @current.plugins = _plugins
      end

      def _plugins
        if File.exist?(@ini_file)
          ini_plugins(@ini_file)
        elsif File.exist?(@composer_file)
          composer_plugins(@composer_file)
        else
          []
        end
      end

      def ini_plugins(ini_file)
        @ini = IniFile.load(@current.dir + '/deps')

        @ini.sections.map do |section|
          {
            name: section,
            status: :active,
            update: :none,
            version: @ini[section]['version']
          }
        end
      end

      def composer_plugins(composer_file)
        composer = JSON.parse(File.read(composer_file))
        composer['packages'].map do |p|
          {
            name: p['name'].split('/')[1],
            status: :active,
            update: :none,
            version: p['version']
          }
        end
      end
    end
  end
end
