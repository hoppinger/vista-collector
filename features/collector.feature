Feature: Manage Wordpress Installations
  Background:
    Given there are default settings
    And there is a Wordpress Collector
    And its vhost folder is set correct

    Scenario: WP download
      Given a WP install

    Scenario: Download test
      When I run `wp core is-installed`
      Then it should be empty

    Scenario: Website
      When I collect all websites
      Then the website `blog_name` should be "WPCLI-Testing"
      And the website `version` should be "latest"

    Scenario: Plugin
      When I collect all websites
      Then the website plugins should have "akismet"

    Scenario: Cleanup
      Then I clean it up after