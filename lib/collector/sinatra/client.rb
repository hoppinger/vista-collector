module Collector
  module Sinatra

    class Client < Collector::Client

      CMS_TYPE = :sinatra

      def initialize
        super
      end

      def find_client_installs
        find_installs
      end

      def collect_single(website)
        command = Collector::Sinatra::Command.new(website)
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
