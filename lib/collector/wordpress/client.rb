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

      def check_latest_wp_version
        url = URI.parse('http://api.wordpress.org/core/version-check/1.6')
        r = Net::HTTP.get_response(url)
        if r.code == "301"
            url = URI.parse(r.header['location'])
        end

        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end

        result = PHP.unserialize(res.body)
        result['offers'].first['current']
      end

    end

  end
end
