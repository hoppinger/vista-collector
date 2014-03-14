Then /^it should be empty$/ do
  @result.should be_empty
end

Then /^I clean it up after$/ do
  install_dir = File.expand_path("../../../download", __FILE__)
  @result = `cd #{install_dir} && wp db reset --yes`
  FileUtils.rm_rf(install_dir)
  Dir.exists?(install_dir).should be_false
  @result.should include("Success")
end

Then /^the website `([^`]+)` should be "([^"]+)"$/ do |field, value|
  @client.websites.should_not be_empty
  @website = @client.websites.first
  value = @client.wp_version if value == "latest"
  @website.send(field).should eq(value)
end

Then /^the website plugins should have "([^"]+)"$/ do |plugin_name|
  @client.websites.should_not be_empty
  @website = @client.websites.first
  @website.plugins.should_not be_empty
  @plugin = @website.plugins.first
  @plugin["name"].should eq(plugin_name)
end