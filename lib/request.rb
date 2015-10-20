require 'net/http'
require 'uri'

class Request

  def initialize(server, port, options = {})
    @server = server
    @port = port

    @options = options

    validate_uri(api_location)
  end

  #
  # Sends the json info to the master server
  # and returns the response code. It should
  # be 200 (OK) if everything went right.
  #
  def send(resource, result)
    uri = URI(api_location + resource)

    request = Net::HTTP::Post.new(uri.path,
      initheader = {'Content-Type' => 'application/json'})
    request = prepare_basic_auth(request)

    request.body = result.to_json
    response     = Net::HTTP.new(uri.host, uri.port).start do |http|
      http.read_timeout = 200
      http.request(request)
    end

    response.code
  end

  #
  # If user has defined basic auth in the
  # settings, they should be added to the
  # HTTP request.
  #
  def prepare_basic_auth(request)
    user = @options[:user] || nil
    pass = @options[:pass] || nil

    request.basic_auth user, pass
    request
  end

  #
  # Validates the url given in the settings
  # file. If it's not valid, an exception is
  # raised.
  #
  def validate_uri(url)
    !!URI.parse(url)
  end

  def api_location
    "http://#{@server}:" + @port
  end

end