require 'popen4'
require 'highline/import'
require 'logger'

module Collector
  class Command

    def initialize current
      @logger = Logger.new('log/command.log', 10, 1024000)
      @logger.formatter = Logger::Formatter.new
    end

    # Perform a command line process and read it's output.
    def execute(cmd, &block)
      output = nil
      error  = nil

      @logger.debug "Parsing command '#{cmd}'"
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
        @logger.warn "Error parsing json in #{current.dir}"
        output = nil
      end
    end

    def site_meta
      meta_location = @current.vhost + '/' + @current.dir.sub(current.vhost, '').split('/').reject(&:empty?).first + '/site-meta.json'

      @current.meta = {};

      begin
        meta_file = File.read(meta_location)
        @current.meta = JSON.parse(meta_file)
      rescue Errno::ENOENT
        @logger.warn "Couldn't find meta_data at location #{meta_location}"
      rescue JSON::ParserError
        @logger.warn "Error parsing json from #{meta_location}"
      end
    end
  end

  class WpCliErrorException < Exception; end;
end
