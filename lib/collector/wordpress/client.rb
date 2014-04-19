module Collector
  module Wordpress

    class Client < Collector::Client

      CMS_TYPE = :wordpress

      def initialize
        super
        @version = check_latest_wp_version
      end

      def find_client_installs
        find_installs ["wp-config.php"]
      end

      def collect_single(website)
        command = Collector::Wordpress::Command.new(website)
        website.type = :wordpress
        begin
          command.blog_name; command.version; command.plugins
        rescue
          website.nullify
        end
      end

    end

  end
end
