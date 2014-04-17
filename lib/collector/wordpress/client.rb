module Collector
  module Wordpress

    class Client < Collector::Client

      def initialize
        super
        @version = check_latest_wp_version
      end

      def collect_all
        installs = find_wordpress_installs

        installs.each do |wp_install|
          website = Collector::Website.new(@config[:vhost_folders], wp_install)
          @websites << website
          result = self.collect_single(website)
        end
      end

      def find_wordpress_installs
        wp_directories = find_installs ["wp-config.php"]
      end

      def collect_single(website)
        command = Collector::Wordpress::Command.new(website)
        website.type = :wordpress
        begin
          command.blog_name; command.version; command.plugins
          true
        rescue
          false
        end
      end

    end

  end
end
