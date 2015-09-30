require 'popen4'
require 'highline/import'

module Collector
  class Command

    # Perform a command line process and read it's output.
    def execute(cmd, &block)
      output = nil
      error  = nil

      say("<%= color('[stdout]:', :green) %> Parsing command '#{cmd}'")
      status = POpen4.popen4(cmd) do |stdout, stderr|
        yield(stdout.read.strip, stderr.read.strip)
      end
    end

    # JSON output consists of keywords that are not used 1:1. These
    # are converted to correct boolean values and method definitions.
    def json_parse(info)
      begin
        output = JSON.parse(info)
      rescue JSON::ParserError
        say("<%= color('[stderr]:', :red) %> Error parsing json in #{current.dir}")
        output = nil
      end
    end

    def site_meta
      meta_location = @current.vhost + '/' + @current.dir.sub(current.vhost, '').split('/').reject(&:empty?).first + '/site-meta.json'

      begin
        meta_file = File.read(meta_location)
        @current.meta = JSON.parse(meta_file)
      rescue Errno::ENOENT
        say("<%= color('[stderr]:', :red) %> Couldn't find meta_data at location #{meta_location}")
        @current.meta = nil
      rescue JSON::ParserError
        say("<%= color('[stderr]:', :red) %> Error parsing json from #{meta_location}")
        @current.meta = nil
      end

    end

  end

  class WpCliErrorException < Exception; end;
end