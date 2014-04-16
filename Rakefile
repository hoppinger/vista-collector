# Rakefile

require "./lib/collector"

namespace :wordpress do
  task :collect_all do
    collector = Collector::Wordpress::Client.new

    collector.collect_all
    collector.send_data
  end

  task :collect_and_debug do
    collector = Collector::Wordpress::Client.new

    result = collector.collect_all
    binding.pry
  end
end

namespace :drupal do
  task :collect_all do
    collector = Collector::Drupal::Client.new

    collector.collect_all
    collector.send_data
  end

  task :collect_and_debug do
    collector = Collector::Drupal::Client.new

    result = collector.collect_all
    binding.pry
  end
end