# Vista Collector
The Collector is a Ruby script client which persists Wordpress plugin, Drupal module and core versions to a Vista master server.
To collect the Wordpress/Drupal data, the app uses [WP-CLI](https://github.com/wp-cli/wp-cli) and [Drush](https://www.drupal.org/project/drush), so be sure to install that first on your servers.

## Requirements

* Ruby >= 2.2.3
* Bundle
* WP-CLI >= master
* Drush
* [Vista Drush](https://github.com/tolgap/drush-vista)

## Installation 
To install you simply need to clone it and install the dependencies with bundle

    # On your server with all website directories
    git clone git@github.com:tolgap/vista-collector.git
    cd vista-collector/

Install the gems with bundler

    bundle install

Proceed to set up the settings file in the config folder

    cd config/
    cp example-settings.rb settings.rb
    
If you enable predefined lists, then copy the example-directories.json

    cd config/
    cp example-directories.json directories.json

**It has to be called `settings.rb` because that's what the `collector.rb` clients will be looking for.**
### Cron
Because this will be called by a cron job in production we have the following ENV variables build in
* WP_CLI
* DRUSH

The cron is currently managed by puppet in the hoppinger_vista module. The ENV's can be set with heira if the module is included. The location of the vista server can also be set.
```
hoppinger_vista_collector::drush_location: '/usr/local/bin/drush'
hoppinger_vista_collector::wp_location: `/user/local/bin/wp`
hoppinger_vista_collector::vista_server: 'vista.test.hoppinger.com'
```

For debugging purpose the cron logs it's output to `cron.log` and `cron_error.log`

### Installing on a server
We have a puppet manifest that will install the collector under the deployer user.
Sadly not all of our servers have rbenv with bundle installed.

In this case you should [install rbenv](https://github.com/rbenv/rbenv#installation).
Also [install Ruby Build](https://github.com/rbenv/ruby-build#installation).
Then install ruby 2.2.3
```
rbenv install 2.2.3
```
If this fails it's probapply because of libreadline. In that case you can run the apt-get install command rbenv tells you to use.
While you are at it you should also set 2.2.3 as default (only if there isn't a default set already)
```
rbenv global 2.2.3
```
Then install bundler
```
rbenv exec gem install bundler
```
And rehash
```
rbenv rehash`
```

### Running without cron jobs
Although this project is set up to be autonomous using cron jobs, you can run the Collector manually using this command

    cd -vista-collector/
    bundle exec rake collect_all

And it will push the data to the master server.
