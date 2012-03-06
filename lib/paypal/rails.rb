require 'active_support'
require File.join(File.dirname(__FILE__),'config')
require File.join(File.dirname(__FILE__),'helpers', '/common')
require File.join(File.dirname(__FILE__),'helpers', '/rails')
require File.join(File.dirname(__FILE__),'notification')

ActionView::Base.send(:include, Paypal::Helpers::Common)
ActionView::Base.send(:include, Paypal::Helpers::Rails)