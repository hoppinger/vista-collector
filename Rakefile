# Rakefile

require "./lib/collector"

task :collect_all do
  collector = Collector::Client.new

  collector.collect_all
  collector.send_data
end

task :collect_and_debug do
  collector = Collector::Client.new

  result = collector.collect_all
  binding.pry
end