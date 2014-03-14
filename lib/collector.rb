require './ext/string_to_underscore'
require './lib/collector/client'
require './lib/collector/command'
require './lib/collector/request'
require './lib/collector/website'
require './config/settings'
require 'uri'
require 'net/http'
require 'php_serialize'
require 'pry'

module Collector
  attr_reader :config

  def load_settings
    @config = Settings.config
  end

  def find_wordpress_installs
    wp_directories = []
    glob_dir = File.join(@config[:vhost_folders], "")
    Dir.glob("#{glob_dir}**/wp-config.php").each do |wp_config_file|
      wp_directories << File.dirname(wp_config_file).gsub(@config[:vhost_folders], "")
    end

    wp_directories
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

if __FILE__ == $0
  client = Collector::Client.new
  website = Collector::Website.new(client.config[:vhost_folders], 'tdior/httpdocs')
  client.collect_single(website)
end