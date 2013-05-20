# WP Vista Collector
The Collector is a Ruby script. It is the client which persists the Wordpress plugin and core data to a Master Server.
To collect the Wordpress data, the app uses [WP-CLI](https://github.com/wp-cli/wp-cli), so be sure to install that first on your servers.

## Requirements

* WP-CLI >= master
* Ruby >= 1.9

## Installation Clients
You put the Clients on a server with Wordpress projects. You set up the cron job (which is a single command), and they will run on the intervals you set up.

    # On your server with all the Wordpress directories
    git clone git@github.com:tolgap/wp-vista-collector.git
    cd wp-vista-collector/

Proceed to set up the settings file in the config folder

    cd config/
    cp example-settings.rb settings.rb

**It has to be called `settings.rb` because that's what the `Collector.rb` clients will be looking for.**

### Setup the cron job for Clients
Of course, you want the clients to work autonomously. This is done by setting up a cron job. The gem `whenever` is used for this. The `whenever` gem will setup your crontab with values in your `settings.rb` intervals.

    cd wp-overview-ruby
    # Check whether your cron job looks ok (!!this does not change anything yet, don't worry!!)
    whenever
    # output => 0,10,20,30,40,50 * * * * /bin/bash -l -c 'cd /your/dir/ && RAILS_ENV=production bundle exec rake collect_all --silent'
    # If that looks ok, then update your crontab using
    whenever --update-crontab

And your Clients will start pushing data to the server you set up in the `settings.rb` file in the intervals you also defined in there.