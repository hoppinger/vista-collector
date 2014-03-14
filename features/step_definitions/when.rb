When /^I run `([^`]+)`$/ do |cmd|
  install_dir = File.expand_path("../../../download", __FILE__)
  @result = `cd #{install_dir} && #{cmd}`
end

When /^I collect all websites$/ do
  @client.collect_all
end

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
  @webiste = @client.websites.first
  value = @client.wp_version if value == "latest"
  @website.send(field).should eq(value)
end