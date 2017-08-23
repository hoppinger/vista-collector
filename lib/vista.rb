require "./lib/request"
require "./lib/request_vista"

class Vista

  def initialize()
    Encoding.default_external = 'UTF-8'

    Dir.mkdir('log') unless File.exists?('log')

    @logger = Logger.new('log/vista.log', 10, 1024000)
    @logger.formatter = Logger::Formatter.new

    @config = Settings.config
    @websites = []
  end

  def collect *collectors
    collectors.each(&:collect_all);
    @websites = collectors.reduce([]) { |acc, collectors| acc + collectors.websites }

    @logger.debug @websites.reduce("") { |acc, w| "#{acc} \n #{w.dir} #{w.type} #{w.version}" }

    server_info = File.read(@config[:server_info_file])
    server_info_lines = server_info.split("\n")

    server_info = {}

    server_info_lines.each do |line|
      key_and_value = line.split("=")
      server_info.merge(key_and_value.first => key_and_value.last)
    end

    @server_info = server_info

  end

  def send_data
      request = Request.new(
        @config[:master_server],
        @config[:master_server_port],
        {
          user: @config[:htpasswd_user],
          pass: @config[:htpasswd_pass],
          api_token: @config[:api_token]
        }
      )

      # convert the array of object to a hash
      server = {
        websites: @websites.map{ |w| w.to_hash(@version).merge({server: @config[:client_name].underscore }) }.map{ |w| w[:website] },
        name: @config[:client_name].underscore,
        client: @server_info[:client],
        otap: @server_info[:otap]
      }

      puts request.send('/collector', server)

      if @config.key?("vista_server")
        request2 = RequestVista.new(
          @config[:vista_server],
          @config[:master_server_port],
          {
            user: @config[:htpasswd_user],
            pass: @config[:htpasswd_pass]
          }
        )

        # convert the array of object to a hash
        server2 = {
          websites: @websites.map{ |w| w.to_hash(@version).merge({server: @config[:client_name].underscore }) }.map{ |w| w[:website] },
          name: @config[:client_name].underscore
        }

        request.send('/servers', server)
      end
  end

end
