module Collector
  module Drupal

    class Client < Collector::Client

      CMS_TYPE = :drupal

      def initialize
        super
      end

      def find_client_installs
        find_installs
      end

      def collect_single(website)
        command = Collector::Drupal::Command.new(website)
        website.type = :drupal

        command.blog_name
        command.version
        command.plugins
        command.site_meta

      end

    end

  end
end