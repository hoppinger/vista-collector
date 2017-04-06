# Rakefile

require "./lib/collector"
require "./lib/vista"

task :collect_all do
  vista = Vista.new

  vista.collect(
    Collector::Rails::Client.new,
    Collector::Sinatra::Client.new,
    Collector::Wordpress::Client.new,
    Collector::Drupal::Client.new,
    Collector::Symfony::Client.new
  )
  vista.send_data
end

task :collect_and_debug do
  vista = Vista.new

  vista.collect(
    Collector::Rails::Client.new,
    Collector::Sinatra::Client.new,
    Collector::Wordpress::Client.new,
    Collector::Drupal::Client.new,
    Collector::Symfony::Client.new
  )

  binding.pry
end
