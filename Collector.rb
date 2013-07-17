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
    @config = Settings.config

    @@dir    = @config[:vhost_folders]
    @@host   = @config[:master_server]
    @@port   = @config[:master_server_port]
    @@server = @config[:client_name]

    unless @config[:htpasswd_user].empty?
      @@user = @config[:htpasswd_user] 
    else
      @@user = nil
    end

    unless @config[:htpasswd_pass].empty?
      @@pass = @config[:htpasswd_pass] 
    else
      @@pass = nil
    end
  end

  def collect_all
    all = Array.new
    Dir.glob("#{@@dir}**/wp-config.php").each do |wp_dir|
      wp = wp_dir[0..-15].sub!(@@dir, "")
      data = gather(wp)

      all << data
    end

    complete = {"server" => @@server, "data" => all}

    path_all = "/save-all"
    send_result(path_all, complete)
  end

  def gather (website_folder)
    data          = @@dir + website_folder
    cli_plugin    = "cd #{data} && wp plugin list --format=json"
    cli_blogname  = "cd #{data} && wp option get blogname"
    cli_version   = "cd #{data} && wp core version"

    # Initialize the fields
    website_errors = Array.new
    plugins = Array.new
    blog_name = ""
    version = ""

    # Call the command line to parse Wp-cli plugin data
    status = POpen4.popen4(cli_plugin) do |stdout, stderr|
      output = stdout.read
      error  = stderr.read
      if (!output.empty?)
        plugins = JSON.parse(output)
      else
        website_errors << error
        say "<%= color('ERROR:', :red) %> #{error} for installation in <%= color('#{website_folder}', :red) %>"
      end
    end

    # Call the command line to parse Wp-cli blog name
    status = POpen4.popen4(cli_blogname) do |stdout, stderr|
      output = stdout.read
      if (!output.empty?)
        blog_name = output
        say "<%= color('PARSED SITE:', :green) %> #{blog_name}"
      end
    end

    # Call the command line to parse Wp-cli core version
    status = POpen4.popen4(cli_version) do |stdout, stderr|
      output = stdout.read
      if (!output.empty?)
        version = output
      end
    end

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

  def send_result (path, result)
    request = Net::HTTP::Post.new(path, initheader = {'Content-Type' => 'application/json'})
    unless (@@user.nil? && @@pass.nil?)
      request.basic_auth @@user, @@pass
    end
    request.body = result.to_json
    response     = Net::HTTP.new(@@host, @@port).start { |http|
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
