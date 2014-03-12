class Collector
  require './config/settings'
  require './lib/dispatcher'
  require './lib/wordpress'

  include Dispatcher
  include Wordpress

  WP_CLI_COMMANDS = {
    blog_name: { cmd: 'wp option get blogname',       json: false },
    version:   { cmd: 'wp core version',              json: false },
    plugins:   { cmd: 'wp plugin list --format=json', json: true },
  }

  attr_accessor :dir, :host, :port, :server, :user, :pass

  def initialize
    self.load_settings # => @see lib/dispatcher
    @wp_current_ver = Wordpress::API.check_latest_wp_version # => @see lib/wordpress/api
  end

  def collect_all
    installs = find_wordpress_installs

    installs.each do |wp_install|
      result = self.collect_single(wp_install)
    end
  end

  def collect_single(folder)
    collected_info = {}
    cd = "cd #{File.join(self.dir, folder)}"
    WP_CLI_COMMANDS.each do |type, sh|
      collected_info[type] = Dispatcher::Command.execute([cd, sh[:cmd]], sh[:json])
    end

    result = prepare_wp_data(collected_info, folder)
    request = Dispatcher::Request.new(self.location, :user => self.user, :pass => self.pass)
    request.send(result)
  end

  def location
    "http://#{self.host}:#{self.port}/servers/#{self.server}/websites/save.json"
  end

  #
  # Prepares the data collected from the command
  # line into a json string that will be sent
  # to the master server. The master server should
  # be able to parse this directly, as the prepared
  # hash is already in to correct params[:website].
  #
  def prepare_wp_data(data, folder)
    has_update = data[:version][:stdout] == @wp_current_ver
    has_errors = data[:plugins][:stdout].nil?
    project_name = File.split(folder).first # Extract first folder name

    wp_data = {
      website: {
        website_errors: "",
        name: project_name,
        has_update: has_update,
        has_errors: has_errors,
      },
      plugins: data.delete(:plugins)[:stdout]
    }

    data.each do |type, cli_info|
      wp_data[:website][type] = cli_info[:stdout]
      wp_data[:website][:website_errors] << cli_info[:stderr]
    end

    wp_data
  end
end
