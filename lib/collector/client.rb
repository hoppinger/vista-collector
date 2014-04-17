module Collector
  class Client
    include Collector

    attr_accessor :version, :websites

    def initialize
      load_settings
      @websites = []
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
