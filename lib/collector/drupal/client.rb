module Collector
  module Drupal

    class Client < Collector::Client

      CMS_TYPE = :drupal

      def initialize
        super
      end

      def find_client_installs
        find_installs ["modules", "sites"]
      end

      def collect_single(website)
        command = Collector::Drupal::Command.new(website)
        website.type = :drupal
        begin
          command.blog_name; command.version; command.plugins
        rescue
          website.nullify
        end
      end

    end

  end
end