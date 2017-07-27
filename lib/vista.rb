require "./lib/request"

class Vista

  def initialize()
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
        name: @config[:client_name].underscore
      }

      request.send('/collector', server)
  end

end
