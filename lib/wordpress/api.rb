module Wordpress

  class API
    require 'uri'
    require 'net/http'
    require 'php_serialize'

    def self.check_latest_wp_version
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
end