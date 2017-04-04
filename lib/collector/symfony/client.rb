module Collector
  module Symfony

    class Client < Collector::Client

      CMS_TYPE = :symfony

      def initialize
        super
      end

      def find_client_installs
        find_installs
      end

      def collect_single(website)
        command = Collector::Symfony::Command.new(website)
        website.type = CMS_TYPE

        command.blog_name
        command.version
        command.plugins
        command.site_meta

      end

    end

  end
end
