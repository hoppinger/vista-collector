module Settings
  @settings = {
    :client_name        => 'client_name',  # A unique name for this Collector client.
    :master_server      => '',           # For example 'http://www.server.com/path'.
    :master_server_port => '',                            # The port for your server. Default Sinatra port set.
    :predefined_list?   => ,                            # Predefined list of directories in config folder?
    :interval_unit      => '',                           # For example 'days', 'week', 'hour'.
    :interval_quantity  => 1,                                # How often you want to run the info job based on your interval unit.
    :vhost_folders      => '',                      # This point to your directory where all your project folders are located.
    :htpasswd_user      => '',                            # The basic auth user.
    :htpasswd_pass      => '',              # The basic auth password.
    :api_token          => '',
    :cms                => {
      :wordpress => [
        ['wp-cli.yml'],
        ['wp-config.php'],
      ],
      :drupal => [
        ['sites', 'modules', 'includes'],
      ],
      :rails => [
        ['Gemfile', 'Gemfile.lock', 'app', 'db', 'public']
      ],
      :sinatra => [
        ['config.ru', 'Gemfile', 'app.rb'],
        ['config.ru', 'Gemfile', 'server.rb']
      ],
      :symfony => [
        ['deps', 'app', 'bin'],
        ['AppKernel.php'],
        ['SymfonyRequirements.php']
      ]
    },
    :max_depth          => 4,
    :ignore_folders     => [],
  }

  def self.config
    @settings
  end
end