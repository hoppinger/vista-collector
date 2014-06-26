# Vista Collector
The Collector is a Ruby script client which persists Wordpress plugin, Drupal module and core versions to a Vista master server.
To collect the Wordpress/Drupal data, the app uses [WP-CLI](https://github.com/wp-cli/wp-cli) and [Drush](https://www.drupal.org/project/drush), so be sure to install that first on your servers.

## Requirements

* Ruby >= 1.9.3
* WP-CLI >= master
* Drush
* Vista Drush

## Installation Clients
You put the Clients on a server with Wordpress projects. You set up the cron job (which is a single command), and they will run on the intervals you set up.

    # On your server with all website directories
    git clone git@github.com:tolgap/vista-collector.git
    cd vista-collector/

Install the gems with bundler

    bundle install

Proceed to set up the settings file in the config folder

    cd config/
    cp example-settings.rb settings.rb

**It has to be called `settings.rb` because that's what the `collector.rb` clients will be looking for.**

## Tests
To run the `cucumber` tests, you need to allocate a database for `WP-CLI` to download Wordpress installations and set up it's database. This can be done from a simple script included.

    cd vista-collector/
    script/db_user

Enter your MySQL admin user and the password and it will create a `wp_cli_test` user and database, identified with the password `password1`.

Then you can run the cucumber tests:

    bundle exec cucumber

### The operation can take a lot of time
The actual fetching of data using WP-CLI takes a lot of time, as it has to query multiple requests to the Wordpress.org repository to find out of the plugins need an update or not. So the rules are simple: the more websites you have running in your directory, the longer it will take. It usually takes around 3 seconds per website to gather the data.

The Drupal data fetching takes even more time. It's estimated that an average website, with about 20 modules, takes a full minute.

### Setup the cron job for Clients
Of course, you want the clients to work autonomously. This is done by setting up a cron job. The gem `whenever` is used for this. The `whenever` gem will setup your crontab with values in your `settings.rb` intervals.

    cd vista-collector/
    # Check whether your cron job looks ok (!!this does not change anything yet, don't worry!!)
    whenever
    # output => 0,10,20,30,40,50 * * * * /bin/bash -l -c 'cd /your/dir/ && RAILS_ENV=production bundle exec rake collect_all --silent'
    # If that looks ok, then update your crontab using
    whenever --update-crontab

And your Vista clients will start pushing data to the server you set up in the `settings.rb` file in the intervals you also defined in there.

### Running without cron jobs
Although this project is set up to be autonomous using cron jobs, you can run the Collector manually using this command

    cd -vista-collector/
    bundle exec rake collect_all

And it will push the data to the master server.
