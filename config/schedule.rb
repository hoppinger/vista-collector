env :PATH, ENV['PATH']

require './config/settings'
require './lib/collector'

cms      = Settings.config[:cms]
interval = Settings.config[:interval_quantity]
unit     = Settings.config[:interval_unit]

every interval.send(unit) do
  [cms].flatten.each do |cms_type|
    rake "#{cms_type}:collect_all"
  end
end