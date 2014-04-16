env :PATH, ENV['PATH']

require './config/settings'
require './lib/collector'

cms      = Settings.config[:cms]
interval = Settings.config[:interval_quantity]
unit     = Settings.config[:interval_unit]

every interval.send(unit) do
  cms.each do |cms_type|
    Thread.new { rake "#{cms_type}:collect_all" }
  end
end