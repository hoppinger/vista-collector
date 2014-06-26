require './ext/string_to_underscore'
require './lib/collector/client'
require './lib/collector/command'
require './lib/collector/request'
require './lib/collector/website'
require './lib/collector/wordpress/client'
require './lib/collector/wordpress/command'
require './lib/collector/drupal/client'
require './lib/collector/drupal/command'
require './config/settings'
require 'find'
require 'uri'
require 'net/http'
require 'php_serialize'
require 'pry'

module Collector
  attr_reader :config

  def load_settings
    @config = Settings.config
  end

  # Find installations based on matches set in the Client classes
  # The Find Module can match a directory and prune it, so it backs
  # out of the directory and does not keep recursing on it.
  # It is much more efficient than just recursing further over it once you've
  # matched your installation.
  def find_installs matches
    directories = []
    glob_dir = File.join(@config[:vhost_folders], "")
    Find.find(glob_dir) do |path|
      if FileTest.directory?(path)
        begin
          if (Dir.entries(path) & matches).size == matches.size
            folder = path.gsub(glob_dir, "")
            add_directory(directories, folder)
            Find.prune
          else
            next
          end
        rescue Errno::EACCES
          next
        end
      end
    end
    directories
  end

  # Add the target path of your installation to your directories.
  # If you somehow have a releases folder and a current folder, this will
  # filter out the most current one.
  def add_directory(directories, path)
    target = Pathname(path).each_filename.to_a.first
    if directories.select{|s| Pathname(s).each_filename.to_a.first == target}.empty?
      directories << path
    end
  end
end
