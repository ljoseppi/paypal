module Paypal
  module Helpers
    module Rails
      # Convenience helper. Can replace <%= form_tag Paypal::Notification.ipn_url %>
      # takes optional url parameter, default is Paypal::Notification.ipn_url
      def paypal_form_tag(url = Paypal::Notification.ipn_url, options = {})
        form_tag(url, options)
      end

      def paypal_form_tag(url = Paypal::Notification.ipn_url, options = {}, &block)
        if block
          concat(form_tag(url, options)+capture(&block)+"</form>", block.binding)
        else
          form_tag(url, options)
        end
      end
    end
  end
end