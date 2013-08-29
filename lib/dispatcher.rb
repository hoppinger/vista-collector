module Dispatcher
  require './lib/dispatcher/command'
  require './lib/dispatcher/request'

  def load_settings
    config = Settings.config

    self.dir    = config[:vhost_folders]
    self.host   = config[:master_server]
    self.port   = config[:master_server_port]
    self.server = config[:client_name].underscore
    self.user   = config[:htpasswd_user]
    self.pass   = config[:htpasswd_pass]
  end
end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end