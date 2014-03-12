require 'config/settings'
require 'uri'
require 'net/http'
require 'php_serialize'

module Collector
  included do
    attr_accessor :config
  end

  def load_settings
    self.config = Settings.config

    self.dir    = config[:vhost_folders]
    self.host   = config[:master_server]
    config[:master_server_port]   = config[:master_server_port]
    self.server = config[:client_name].underscore
    self.user   = config[:htpasswd_user]
    self.pass   = config[:htpasswd_pass]
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

  class Client
    include Collector

    def initialize
      load_settings
      @wp_version = check_latest_wp_version
    end

    def api_location
      "http://#{config[:master_server]}:" +
      "#{config[:master_server_port]}/servers/" +
      "#{config[:client_name].underscore}/websites/save.json"
    end

  end
end