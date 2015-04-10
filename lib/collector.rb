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
require 'tree'
require 'uri'
require 'net/http'
require 'php_serialize'
require 'pry'

module Collector
  attr_reader :config

  def load_settings
    @config = Settings.config
  end

  def build_directory_tree node, max_depth
    return if node.node_depth > max_depth
    Dir.foreach(node.content) do |file_path|
      next if @config[:ignore_folders].include?(file_path)
      path = "#{node.content}/#{file_path}"
      child_node = Tree::TreeNode.new(file_path, path)
      node << child_node
      begin
        if FileTest.directory?(path)
          build_directory_tree child_node, max_depth
        end
      rescue Errno::EACCES
        next
      end
    end
    node
  end

  # [{type, path}]
  def get_websites_from node
    type = get_folder_type node
    if type
      return [{
        :type => type,
        :path => node.content,
      }]
    else
      childs = []
      node.children.each do |child|
        childs += get_websites_from child
      end
      return childs
    end
  end

  # Find installations based on matches set in the Client classes
  # The Find Module can match a directory and prune it, so it backs
  # out of the directory and does not keep recursing on it.
  # It is much more efficient than just recursing further over it once you've
  # matched your installation.
  def find_installs matches
    tree = build_directory_tree (Tree::TreeNode.new "ROOT", @config[:vhost_folders]), @config[:max_depth]
    websites = get_websites_from tree

    directories = websites.map do |website|
      if website[:type] == self.class::CMS_TYPE
        website[:path]
      end
    end.compact!

    directories
  end

  def get_folder_type node

    children = node.children.map do |child|
      child.name
    end

    @config[:cms].each do |cms, match_sets|
      match_sets.each do |match_set|
        #["sites", "modules", "themes", "web.config"]

        matches = match_set.map do |match|
          children.include?(match)
        end

        if !matches.include?(false)
          return cms
        end

      end
    end

    false
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
