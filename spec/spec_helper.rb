$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'paypal'
require 'spec'
require 'fakeweb'
require 'spec/autorun'

# Do not allow connection to non registered URLs, so we can catch if specifics were called
FakeWeb.allow_net_connect = false

Spec::Runner.configure do |config|
end