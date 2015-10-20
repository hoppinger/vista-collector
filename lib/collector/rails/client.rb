module Collector
  module Rails

    class Client < Collector::Client

      CMS_TYPE = :rails

      def initialize
        super
      end

      def find_client_installs
        find_installs
      end

      def collect_single(website)
        command = Collector::Rails::Command.new(website)
        website.type = CMS_TYPE

        command.blog_name
        command.version
        command.plugins
        command.site_meta
        command.meta

      end

    end

  end
end
