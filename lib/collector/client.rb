module Collector
  class Client
    include Collector

    attr_accessor :version, :websites

    def initialize
      load_settings
      @websites = []
    end

    def find_client_installs
      MethodNotImplementedError.new "Please implement this method"
    end

    def collect_all
      installs = find_client_installs

      installs.each do |install|
        website = Collector::Website.new(@config[:vhost_folders], install)
        @websites << website
        collect_single(website)
      end
    end

    def send_data
      request = Collector::Request.new(self.api_location,
        :user => config[:htpasswd_user],
        :pass => config[:htpasswd_pass])

      @websites.each do |website|
        request.send(website.to_hash(@version).merge({
          server: config[:client_name].underscore,
        }))
      end
    end

    def api_location
      "http://#{config[:master_server]}:" +
      "#{config[:master_server_port]}/servers/" +
      "#{config[:client_name].underscore}/websites/create_or_update.json"
    end
  end
end

class MethodNotImplementedError < Exception; end