require 'openssl'

class Request

  def initialize(server, port, options = {})
    @logger = Logger.new('log/request.log', 10, 1024000)
    @logger.formatter = Logger::Formatter.new
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
      initheader = {
        'Content-Type' => 'application/json',
	'ApiToken' => @options[:api_token]
    })
    request = prepare_basic_auth(request)

    @logger.debug "Send: #{resource}"

    request.body = result.to_json.to_s

    response = Net::HTTP.start(uri.host, uri.port,
      :verify_mode => OpenSSL::SSL::VERIFY_NONE,
      :use_ssl => uri.scheme == 'https') do |http|
         http.read_timeout = 500
         http.request(request)
    end

    @logger.debug "#{resource}, #{response.code}"
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
    "https://#{@server}:" + @port
  end

end