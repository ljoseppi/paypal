require 'rack'
require 'net/http'

module Paypal
  class NoDataError < StandardError; end
  
  # Parser and handler for incoming Instant payment notifications from paypal. 
  # The Example shows a typical handler in a rails application. Note that this
  # is an example, please read the Paypal API documentation for all the details
  # on creating a safe payment controller.
  #
  # Example (Sinatra)
  #   def raw_post
  #     request.env["rack.input"].read
  #   end
  #
  #   post "/paypal_ipn" do
  #     notify = Paypal::Notification.new(raw_post)
  #
  #     order = Order.find(notify.item_id)
  #
  #     if notify.acknowledge
  #       begin
  #         if notify.complete? and order.total == notify.amount and notify.business == 'sales@myshop.com'
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
  #       nil
  #     end
  #   end
  #
  # Example (Rails)
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
      
      uri = URI.parse(Paypal::Config.ipn_url)
      request = Net::HTTP::Post.new(Paypal::Config.ipn_validation_path)
      request['Content-Length'] = "#{payload.size}"
      request['User-Agent']     = "paypal ruby -- http://github.com/JonathanTron/paypal"
      
      http = Net::HTTP.new(uri.host, uri.port)

      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
      http.use_ssl        = true

      request = http.request(request, payload)
        
      raise StandardError.new("Faulty paypal result: #{request.body}") unless ["VERIFIED", "INVALID"].include?(request.body)
      
      request.body == "VERIFIED"
    end
    
    def method_missing(method, *args)
      params[method.to_s] || super
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