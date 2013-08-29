module Wordpress
  require './lib/wordpress/api'

  # Loop over every directory and find
  # Wordpress installs by looking for
  # a wp_config.php file. If there is a
  # file, you can be certain that the
  # directory has a Wordpress installation.
  # The function truncates the base directory,
  # set in the settings.rb file so all that is
  # left is the unique directory for the installation.
  def find_wordpress_installs
    wp_directories = []
    Dir.glob("#{self.dir}**/wp-config.php").each do |wp_config_file|
      wp_directories << File.dirname(wp_config_file).gsub(self.dir, "")
    end

    wp_directories
  end
end