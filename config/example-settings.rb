module Settings
  @settings = {
    :client_name        => "my local projects", # A unique name for this Collector client.
    :master_server      => "localhost",         # For example 'http://www.server.com/path'.
    :master_server_port => "4567",              # The port for your server. Default Sinatra port set.
    :interval_unit      => "minute",            # For example "days", "week", "hour".
    :interval_quantity  => 10,                  # How often you want to run the info job based on your interval unit.
    :vhost_folders      => "/path/to/vhosts/",  # This point to your directory where all your project folders are located.
    :wp_root_folder     => "httpdocs",          # The folder name of all your wp installs. It usually is httpdocs.
    :htpasswd_user      => "",                  # The basic auth user.
    :htpasswd_pass      => ""                   # The basic auth password.
  }

  def self.config
    @settings
  end
end