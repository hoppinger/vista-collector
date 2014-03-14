module Collector
  class Client
    include Collector

    attr_accessor :websites, :wp_version

    def initialize
      load_settings
      @websites = []
      @wp_version = check_latest_wp_version
    end

    def collect_all
      installs = find_wordpress_installs

      installs.each do |wp_install|
        website = Collector::Website.new(@config[:vhost_folders], wp_install)
        @websites << website
        result = self.collect_single(website)
      end
    end

    def collect_single(website)
      command = Collector::Command.new(website)
      command.blog_name; command.version; command.plugins
    end

    def send_data
      request = Collector::Request.new(self.api_location,
        :user => config[:htpasswd_user],
        :pass => config[:htpasswd_pass])

      @websites.each do |website|
        request.send(website.to_hash(@wp_version).merge({
          server: config[:client_name].underscore,
        }))
      end
    end

    def api_location
      "http://#{config[:master_server]}:" +
      "#{config[:master_server_port]}/servers/" +
      "#{config[:client_name].underscore}/websites/save.json"
    end
  end
end