Feature: Manage Wordpress Installations
  Background:
    Given a WP install
    And there are default settings

  Scenario: Download test
    When I run `wp core is-installed`
    Then it should be empty

  Scenario: Collector
    Given there is a Collector
    And its vhost folder is set correct
    When I collect all websites
    Then the website `blog_name` should be "WPCLI-Testing"
    And the website `version` should be "latest"

  Scenario: Cleanup
    Then I clean it up after