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
      data = gather(wp, true)

      if (data != false)
        all << data
      else
        say("<%= color('Error:', :red) %> #{wp} project has either database issues, or other PHP issues. Check your installation")

        array  = {
          "name"       => website_folder,
          "blog_name"  => blog_name,
          "has_update" => has_update,
          "version"    => version,
          "plugins"    => plugins
        }
      end
    end

    complete = {"server" => @@server, "data" => all}

    path_all = "/save-all"
    send_result(path_all, complete)
  end

  def gather (website_folder, extract)
    if (extract)
      data          = @@dir + website_folder
      result        = `cd #{data} && wp plugin list --format=json 2> /dev/null`
      name          = `cd #{data} && wp option get blogname 2> /dev/null`
      versionresult = `cd #{data} && wp core version 2> /dev/null`
    end

    begin
      plugins       = JSON.parse(sanitize(result, "plugin"))
      blog_name     = sanitize(name, "blogname")
      version       = sanitize(versionresult, "version")
      has_update    = version == @wp_current_ver ? "none" : "available"

      array  = {
        "name"       => website_folder,
        "blog_name"  => blog_name,
        "has_update" => has_update,
        "version"    => version,
        "plugins"    => plugins,
        "has_errors"     => false
      }
    rescue
      array  = {
        "name"   => website_folder,
        "has_errors" => true
      }
    end

    array
  end

  def sanitize(result, type="plugin")
    result = result.split("\n")
    if (type === "plugin")
      plugins = result.last
      return plugins
    elsif (type === "blogname")
      blog_name = result.last
      return blog_name
    else
      versionresult = result.last
      return versionresult
    end
  end

  def send_result (path, result)
    request      = Net::HTTP::Post.new(path, initheader = {'Content-Type' => 'application/json'})
    unless (@@user.nil? && @@pass.nil?)
      request.basic_auth @@user, @@pass
    end
    request.body = result.to_json
    response     = Net::HTTP.new(@@host, @@port).start { |http| http.request(request) }
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
