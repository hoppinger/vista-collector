When /^I run `([^`]+)`$/ do |cmd|
  install_dir = File.expand_path("../../../download", __FILE__)
  @result = `cd #{install_dir} && #{cmd}`
end

When /^I collect all websites$/ do
  @client.collect_all
end