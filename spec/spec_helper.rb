$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'paypal'
require 'spec'
require 'fakeweb'
require 'spec/autorun'

FakeWeb.allow_net_connect = false

Spec::Runner.configure do |config|

end
