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
          output.gsub!("\"update\"", "\"has_update\"")
          output = JSON.parse(output)
        end
      rescue JSON::ParserError
        say("<%= color('[stderr:]', :red) %> Error parsing command #{cmds.join(' && ')}")
      end

      { stdout: output, stderr: error, status: status }
    end
  end

end