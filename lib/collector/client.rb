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

      if installs
        installs.each do |install|
          website = Collector::Website.new(@config[:vhost_folders], install)
          @websites << website
          collect_single(website)
        end
      end
    end

    def open_predefined_list
      location = File.expand_path("../../../config/directories.json", __FILE__)
      File.read(location)
    end

    # Send data of all parsed websites and return all their
    # API responses as an array.
    def send_data
      request = Collector::Request.
      new(self.api_location,
        :user => config[:htpasswd_user],
        :pass => config[:htpasswd_pass])

      # convert the array of object to a hash
      server = {
        websites: @websites.map{ |w| w.to_hash(@version).merge({server: config[:client_name].underscore }) }.map{ |w| w[:website] },
        name: config[:client_name].underscore
      }

      request.send(server)

    end

    def api_location
      "https://#{config[:master_server]}:" +
      "#{config[:master_server_port]}/servers"
    end
  end
end

class MethodNotImplementedError < Exception; end
