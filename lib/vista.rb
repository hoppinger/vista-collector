require "./lib/request"

class Vista

  def initialize()
    @config = Settings.config
    @websites = []
  end

  def collect *collectors
    collectors.each(&:collect_all);
    @websites = collectors.reduce([]) { |acc, collectors| acc + collectors.websites }
  end

  def send_data
      request = Request.new(
        @config[:master_server],
        @config[:master_server_port],
        {
          user: @config[:htpasswd_user],
          pass: @config[:htpasswd_pass]
        }
      )

      # convert the array of object to a hash
      server = {
        websites: @websites.map{ |w| w.to_hash(@version).merge({server: @config[:client_name].underscore }) }.map{ |w| w[:website] },
        name: @config[:client_name].underscore
      }

      request.send('/servers', server)
  end

end
