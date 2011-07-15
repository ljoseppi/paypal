require "rubygems"
require "bundler"
Bundler.setup

require "paypal"
require "fakeweb"
require "nokogiri"
require "rspec"

# Do not allow connection to non registered URLs, so we can catch if specifics were called
FakeWeb.allow_net_connect = false

RSpec::Matchers.define :have_css do |css|
  match do |text|
    html = Nokogiri::HTML(text)
    !html.css(css).empty?
  end
 
  failure_message_for_should do |text|
    "expected to find css expression #{css} in:\n#{text}"
  end
 
  failure_message_for_should_not do |text|
    "expected not to find css expression #{css} in:\n#{text}"
  end

  description do
    "have css in #{expected}"
  end
end

RSpec.configure do |c|
  c.mock_framework = :rspec
  c.color_enabled = true
end