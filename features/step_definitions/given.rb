Given /^a WP install$/ do
  install_dir = File.expand_path("../../../download", __FILE__)
  unless Dir.exists? install_dir
    Dir.mkdir(install_dir, 0775)
  end
  `cd #{install_dir} && wp core download`
  `cd #{install_dir} && wp core config --dbname=wp_cli_test --dbuser=wp_cli_test --dbpass=password1`
  `cd #{install_dir} && wp core install --title="WPCLI-Testing" --url="localhost" --admin_user="wpcli" --admin_password="wpcli" --admin_email="admin@exmaple.com"`
end

Given /^there are default settings$/ do
  file = File.expand_path("../../../config/example-settings.rb", __FILE__)
  FileUtils.copy(file, File.expand_path("../settings.rb", file))
end

Given /^there is a Wordpress Collector$/ do
  @client = Collector::Wordpress::Client.new
end

Given /^its vhost folder is set correct$/ do
  @client.config[:vhost_folders] = File.expand_path("../../../", __FILE__)
end

Given /^there is a plugin "([^"]+)"$/ do |plugin_name|
  install_dir = File.expand_path("../../../download", __FILE__)
  `cd #{install_dir} && wp plugin scaffold #{plugin_name}`
end