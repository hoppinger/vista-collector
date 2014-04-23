require 'popen4'
require 'highline/import'

module Collector
  class Command

    def execute(&block)
      output = nil
      error  = nil
      cmd = block.call

      say("<%= color('[stdout]:', :green) %> Parsing command '#{cmd}'")
      status = POpen4.popen4(cmd) do |stdout, stderr|
        output = stdout.read.strip
        error  = stderr.read.strip
      end
      output.split("\n").last
    end

    def json_parse(info)
      begin
        info.gsub!('"update"', '"has_update"')
        info.gsub!('"none"', 'false')
        info.gsub!('"available"', 'true')
        info.gsub!('"security"', 'true')
        output = JSON.parse(info)
      rescue JSON::ParserError
        say("<%= color('[stderr]:', :red) %> Error parsing json in #{current.dir}")
        output = nil
      end
    end

  end
end