require 'rack'
require 'net/http'

module Paypal
  class NoDataError < StandardError; end
  
  # Parser and handler for incoming Instant payment notifications from paypal. 
  # The Example shows a typical handler in a rails application. Note that this
  # is an example, please read the Paypal API documentation for all the details
  # on creating a safe payment controller.
  #
  # Example
  #  
  #   class BackendController < ApplicationController
  #   
  #     def paypal_ipn
  #       notify = Paypal::Notification.new(request.raw_post)
  #   
  #       order = Order.find(notify.item_id)
  #     
  #       if notify.acknowledge 
  #         begin
  #           
  #           if notify.complete? and order.total == notify.amount and notify.business == 'sales@myshop.com'
  #             order.status = 'success' 
  #             
  #             shop.ship(order)
  #           else
  #             logger.error("Failed to verify Paypal's notification, please investigate")
  #           end
  #   
  #         rescue => e
  #           order.status        = 'failed'      
  #           raise
  #         ensure
  #           order.save
  #         end
  #       end
  #   
  #       render :nothing
  #     end
  #   end
  class Notification
    attr_accessor :params
    attr_accessor :raw

    # Overwrite this url. It points to the Paypal sandbox by default.
    # Please note that the Paypal technical overview (doc directory)
    # speaks of a https:// address for production use. In my tests 
    # this https address does not in fact work. 
    # 
    # Example: 
    #   Paypal::Notification.ipn_url = https://www.paypal.com/cgi-bin/webscr
    #
    @@ipn_url = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
    def self.ipn_url
      @@ipn_url
    end
    def self.ipn_url=(new_url)
      @@ipn_url = new_url
    end

    # Overwrite this certificate. It contains the Paypal sandbox certificate by default.
    #
    # Example:
    #   Paypal::Notification.paypal_cert = File::read("paypal_cert.pem")
    @@paypal_cert = """
-----BEGIN CERTIFICATE-----
MIIDoTCCAwqgAwIBAgIBADANBgkqhkiG9w0BAQUFADCBmDELMAkGA1UEBhMCVVMx
EzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBKb3NlMRUwEwYDVQQK
EwxQYXlQYWwsIEluYy4xFjAUBgNVBAsUDXNhbmRib3hfY2VydHMxFDASBgNVBAMU
C3NhbmRib3hfYXBpMRwwGgYJKoZIhvcNAQkBFg1yZUBwYXlwYWwuY29tMB4XDTA0
MDQxOTA3MDI1NFoXDTM1MDQxOTA3MDI1NFowgZgxCzAJBgNVBAYTAlVTMRMwEQYD
VQQIEwpDYWxpZm9ybmlhMREwDwYDVQQHEwhTYW4gSm9zZTEVMBMGA1UEChMMUGF5
UGFsLCBJbmMuMRYwFAYDVQQLFA1zYW5kYm94X2NlcnRzMRQwEgYDVQQDFAtzYW5k
Ym94X2FwaTEcMBoGCSqGSIb3DQEJARYNcmVAcGF5cGFsLmNvbTCBnzANBgkqhkiG
9w0BAQEFAAOBjQAwgYkCgYEAt5bjv/0N0qN3TiBL+1+L/EjpO1jeqPaJC1fDi+cC
6t6tTbQ55Od4poT8xjSzNH5S48iHdZh0C7EqfE1MPCc2coJqCSpDqxmOrO+9QXsj
HWAnx6sb6foHHpsPm7WgQyUmDsNwTWT3OGR398ERmBzzcoL5owf3zBSpRP0NlTWo
nPMCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUgy4i2asqiC1rp5Ms81Dx8nfVqdIwgcUG
A1UdIwSBvTCBuoAUgy4i2asqiC1rp5Ms81Dx8nfVqdKhgZ6kgZswgZgxCzAJBgNV
BAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMREwDwYDVQQHEwhTYW4gSm9zZTEV
MBMGA1UEChMMUGF5UGFsLCBJbmMuMRYwFAYDVQQLFA1zYW5kYm94X2NlcnRzMRQw
EgYDVQQDFAtzYW5kYm94X2FwaTEcMBoGCSqGSIb3DQEJARYNcmVAcGF5cGFsLmNv
bYIBADAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4GBAFc288DYGX+GX2+W
P/dwdXwficf+rlG+0V9GBPJZYKZJQ069W/ZRkUuWFQ+Opd2yhPpneGezmw3aU222
CGrdKhOrBJRRcpoO3FjHHmXWkqgbQqDWdG7S+/l8n1QfDPp+jpULOrcnGEUY41Im
jZJTylbJQ1b5PBBjGiP0PpK48cdF
-----END CERTIFICATE-----
"""
    def self.paypal_cert
      @@paypal_cert
    end
    def self.paypal_cert=(new_cert)
      @@paypal_cert = new_cert
    end
    
    # Creates a new paypal object. Pass the raw html you got from paypal in. 
    # In a rails application this looks something like this
    # 
    #   def paypal_ipn
    #     paypal = Paypal::Notification.new(request.raw_post)
    #     ...
    #   end
    def initialize(post)
      raise NoDataError if post.to_s.empty?

      @params  = {}
      @raw     = ""

      parse(post)
    end

    # Transaction statuses
    def canceled_reversal?
      status == :Canceled_Reversal
    end

    def completed?
      status == :Completed
    end

    def denied?
      status == :Denied
    end

    def expired?
      status == :Expired
    end

    def failed?
      status == :Failed
    end

    def pending?
      status == :Pending
    end

    def processed?
      status == :Processed
    end

    def refunded?
      status == :Refunded
    end

    def reversed?
      status == :Reversed
    end

    def voided?
      status == :Voided
    end

    # Acknowledge the transaction to paypal. This method has to be called after a new 
    # ipn arrives. Paypal will verify that all the information we received are correct and will return a 
    # ok or a fail. 
    # 
    # Example:
    # 
    #   def paypal_ipn
    #     notify = PaypalNotification.new(request.raw_post)
    #
    #     if notify.acknowledge 
    #       ... process order ... if notify.complete?
    #     else
    #       ... log possible hacking attempt ...
    #     end
    def acknowledge
      payload = raw
      
      uri = URI.parse(self.class.ipn_url)
      request_path = "#{uri.path}?cmd=_notify-validate"
      
      request = Net::HTTP::Post.new(request_path)
      request['Content-Length'] = "#{payload.size}"
      request['User-Agent']     = "paypal ruby -- http://github.com/JonathanTron/paypal"
      
      http = Net::HTTP.new(uri.host, uri.port)

      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
      http.use_ssl        = true

      request = http.request(request, payload)
        
      raise StandardError.new("Faulty paypal result: #{request.body}") unless ["VERIFIED", "INVALID"].include?(request.body)
      
      request.body == "VERIFIED"
    end

    private
    
    def status
      @status ||= (params['payment_status'] ? params['payment_status'].to_sym : nil)
    end
    
    # Take the posted data and move the relevant data into a hash
    def parse(post)
      @raw = post
      self.params = Rack::Utils.parse_query(post)
      # Rack allows duplicate keys in queries, we need to use only the last value here
      self.params.each{|k,v| self.params[k] = v.last if v.respond_to?(:last)}
    end
  end
end