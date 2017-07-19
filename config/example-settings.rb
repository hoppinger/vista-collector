module Settings
  @settings = {
    :client_name        => "my_client_name",   # A unique name for this Collector client.
    :master_server      => "localhost",           # For example 'server.com/path'. Don't add www or http://
    :master_server_port => "3000",                # The port for your server. Default Rails port set.
    :cms                => {
      :wordpress => [
        ["wp-cli.yml"],
        ["wp-config.php"],
      ],
      :drupal => [
        ["sites", "modules", "includes"],
      ]
    }, # Which CMSs do you want to index
    :predefined_list?   => false,                 # Predefined list of directories in config folder?
    :interval_unit      => "minute",              # For example "days", "week", "hour".
    :interval_quantity  => 10,                    # How often you want to run the info job based on your interval unit.
    :max_depth          => 4,                     # Max depth to search in
    :vhost_folders      => "/path/to/projects",    # This point to your directory where all your project folders are located.
    :ignore_folders     => [
      '.',
      '..',
      '.git',
      '.node_modules',
      'releases',
      'builds',
      '.bundle'
    ],
    :htpasswd_user      => nil,                   # The basic auth user.
    :htpasswd_pass      => nil,                   # The basic auth password.
    :api_token          => nil                    # The API token
  }

  def self.config
    @settings
  end
end
