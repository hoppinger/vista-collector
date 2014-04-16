require './ext/string_to_underscore'
require './lib/collector/client'
require './lib/collector/command'
require './lib/collector/request'
require './lib/collector/website'
require './lib/collector/wordpress/client'
require './lib/collector/wordpress/command'
require './lib/collector/drupal/client'
require './lib/collector/drupal/command'
require './config/settings'
require 'find'
require 'uri'
require 'net/http'
require 'php_serialize'
require 'pry'

module Collector
  attr_reader :config

  def load_settings
    @config = Settings.config
  end

  def find_installs matches
    directories = []
    glob_dir = File.join(@config[:vhost_folders], "")
    Find.find(glob_dir) do |path|
      if FileTest.directory?(path)
        begin
          if (Dir.entries(path) & matches).size == matches.size
            directories << path.gsub(glob_dir, "")
            Find.prune
          else
            next
          end
        rescue Errno::EACCES
          next
        end
      end
    end
    directories
  end

  def check_latest_wp_version
    url = URI.parse('http://api.wordpress.org/core/version-check/1.6')
    r = Net::HTTP.get_response(url)
    if r.code == "301"
        url = URI.parse(r.header['location'])
    end

    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end

    result = PHP.unserialize(res.body)
    result['offers'].first['current']
  end
end
