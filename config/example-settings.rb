module Settings
  @settings = {
    :client_name        => "my local projects", # A unique name for this Collector client.
    :master_server      => "localhost",         # For example 'server.com/path'. Don't add www or http://
    :master_server_port => "3000",              # The port for your server. Default Rails port set.
    :interval_unit      => "minute",            # For example "days", "week", "hour".
    :interval_quantity  => 10,                  # How often you want to run the info job based on your interval unit.
    :vhost_folders      => "/path/to/vhosts/",  # This point to your directory where all your project folders are located.
    :htpasswd_user      => "",                  # The basic auth user.
    :htpasswd_pass      => ""                   # The basic auth password.
  }

  def self.config
    @settings
  end
end