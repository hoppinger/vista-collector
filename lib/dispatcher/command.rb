module Dispatcher

  class Command
    require 'json'
    require 'popen4'
    require 'highline/import'

    # Execute the WP_CLI commands using the
    # POpen4 gem and return the output as a
    # Hash. The Hash always return these keys:
    # :stdout, :stderr, :status
    def self.execute(cmds = [], json = false)
      output = nil
      error  = nil
      status = POpen4.popen4(cmds.join(' && ')) do |stdout, stderr|
        output = stdout.read.strip
        error  = stderr.read.strip
      end

      begin
        if json
          output.gsub!('"update"', '"has_update"') # WP_CLI uses update, but that method is reserved by ActiveRecord
          output.gsub!('"none"', 'false')     # WP_CLI uses "none", but we use Booleans
          output.gsub!('"available"', 'true') # WP_CLI uses "available", but we use Booleans
          output = JSON.parse(output)
        end
      rescue JSON::ParserError
        output = nil
        say("<%= color('[stderr:]', :red) %> Error parsing command #{cmds.join(' && ')}")
      end

      { stdout: output, stderr: error, status: status }
    end
  end

end