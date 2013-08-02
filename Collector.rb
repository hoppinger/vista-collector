require 'popen4'
require 'highline/import'
require 'json'
require 'net/http'
require 'uri'
require 'php_serialize'

require './config/settings'

class Collector

  def initialize
    @wp_current_ver = Collector.check_latest_wp_version
    config = Settings.config

    @dir    = config[:vhost_folders]
    @host   = config[:master_server]
    @port   = config[:master_server_port]
    @server = config[:client_name]

    unless config[:htpasswd_user].empty?
      @user = config[:htpasswd_user]
    else
      @user = nil
    end

    unless config[:htpasswd_pass].empty?
      @pass = config[:htpasswd_pass]
    else
      @pass = nil
    end
  end

  def collect_all
    all = Array.new
    Dir.glob("#{@dir}**/wp-config.php").each do |wp_dir|
      wp = wp_dir[0..-15].sub!(@dir, "")
      data = gather(wp)

      all << data
    end

    complete = {"server" => @server, "data" => all}

    path_all = "/save-all"
    send_result(path_all, complete)
  end

  def gather (website_folder)
    data          = @dir + website_folder
    cli_plugin    = "cd #{data} && wp plugin list --format=json"
    cli_blogname  = "cd #{data} && wp option get blogname"
    cli_version   = "cd #{data} && wp core version"

    # Initialize the fields
    website_errors = []
    plugins = []
    blog_name = ""
    version = ""

    # Call the command line to parse Wp-cli info
    cli(cli_plugin, website_errors) { |output| plugins = JSON.parse(output)}
    cli(cli_version, website_errors) { |output| version = output }
    cli(cli_blogname, website_errors) { |output| blog_name = output}

    has_update = version == @wp_current_ver ? "none" : "available"
    has_errors = !website_errors.empty?

    array  = {
      "name"           => website_folder,
      "blog_name"      => blog_name,
      "has_update"     => has_update,
      "version"        => version,
      "plugins"        => plugins,
      "has_errors"     => has_errors,
      "website_errors" => website_errors
    }

  end

  def cli(command, website_errors)
    status = POpen4.popen4(command) do |stdout, stderr|
      output = stdout.read
      error  = stderr.read
      if (!output.empty?)
        yield output.gsub("Array", "").chomp
      else
        website_errors << error
        say "<%= color('ERROR:', :red) %> #{error} for installation in <%= color('#{website_folder}', :red) %>"
      end
    end
  end

  def send_result (path, result)
    request = Net::HTTP::Post.new(path, initheader = {'Content-Type' => 'application/json'})
    unless (@user.nil? && @pass.nil?)
      request.basic_auth @user, @pass
    end
    request.body = result.to_json
    response     = Net::HTTP.new(@host, @port).start { |http|
      http.read_timeout = 200
      http.request(request)
    }
  end

  def self.check_latest_wp_version
    url = URI.parse('http://api.wordpress.org/core/version-check/1.6')
    r = Net::HTTP.get_response(url)
    if r.code == "301"
        url = URI.parse(r.header['location'])
    end

    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    result = PHP.unserialize(res.body)
    result['offers'].first['current']
  end

end
