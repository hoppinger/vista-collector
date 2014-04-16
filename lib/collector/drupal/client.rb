module Collector
  module Drupal

    class Client < Collector::Client

      def collect_all
        installs = find_drupal_installs

        installs.each do |wp_install|
          website = Collector::Website.new(@config[:vhost_folders], wp_install)
          add_website(website)
          result = self.collect_single(website)
        end
      end

      def find_drupal_installs
        dp_directories = find_installs ["modules", "sites"]
      end

      def collect_single(website)
        command = Collector::Drupal::Command.new(website)
        website.type = :drupal
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