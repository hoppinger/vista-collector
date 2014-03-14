env :PATH, ENV['PATH']

require './config/settings'
require './lib/collector'

interval = Settings.config[:interval_quantity]
unit     = Settings.config[:interval_unit]

every interval.send(unit) do
  rake "collect_all"
end