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
      if @config[:predefined_list?]
        # Parse the predefined list and use those instead.
        file = JSON.parse(open_predefined_list)
        # Use the client's CMS type.
        installs = file[self.class::CMS_TYPE.to_s]
      else
        # Loop over all website folders and execute their commands to parse
        # the results.
        installs = find_client_installs
      end

      installs.each do |install|
        website = Collector::Website.new(@config[:vhost_folders], install)
        @websites << website
        collect_single(website)
      end
    end

    def open_predefined_list
      location = File.expand_path("../../../config/directories.json", __FILE__)
      File.read(location)
    end

    # Send data of all parsed websites and return all their
    # API responses as an array.
    def send_data
      request = Collector::Request.new(self.api_location,
        :user => config[:htpasswd_user],
        :pass => config[:htpasswd_pass])

      @websites.map do |website|
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