  require 'json'
  require 'net/http'
  require 'uri'
  require 'php_serialize'

  require './config/settings'

  class Collector

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

    def collect_all
      all = Array.new
      Dir.glob("#{@@dir}**/wp-config.php").each do |wp_dir|
        wp = wp_dir[0..-15].sub!(@@dir, "")
        data = gather(wp, true)

        if (data != false)
          all.push(data)
        else
          puts "#{wp} project has either database issues, or other PHP issues. Check your installation"
        end
      end

      complete = {"server" => @@server, "data" => all}

      path_all = "/save-all"
      send_result(path_all, complete)
    end

    def gather (website_folder, extract)
      if (extract)
        data          = @@dir + website_folder
        result        = `cd #{data} && wp plugin list --format=json`
        name          = `cd #{data} && wp option get blogname`
        versionresult = `cd #{data} && wp core version --extra`
      end

      begin
        plugins       = JSON.parse(result)
        blog_name     = name.split("\n").first
        versionresult = versionresult.split("\n")
        versionresult = versionresult[0].split("\t")
        version       = versionresult[1]

        array  = { "name" => website_folder, "blog_name" => blog_name,"version" => version, "plugins" => plugins }
      rescue
        array = false
      end

      array
    end

    def send_result (path, result)
      request      = Net::HTTP::Post.new(path, initheader = {'Content-Type' => 'application/json'})
      unless (@@user.nil? && @@pass.nil?)
        request.basic_auth @@user, @@pass
      end
      request.body = result.to_json
      response     = Net::HTTP.new(@@host, @@port).start { |http| http.request(request) }
    end

    def check_latest_wp_version
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
