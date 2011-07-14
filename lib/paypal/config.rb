module Paypal
  module Config

    @@paypal_config = {}

    def self.ipn_urls
      @@paypal_config[:ipn_urls] ||= {
        :sandbox => "https://www.sandbox.paypal.com/cgi-bin/webscr",
        :production => "https://www.paypal.com/cgi-bin/webscr"
      }
    end

    def self.mode=(new_mode)
      raise ArgumentError.new("Paypal::Config.mode should be either :sandbox or :production (you tried to set it as : #{new_mode})") unless [:sandbox, :production].include?(new_mode.to_sym)
      @@paypal_config[:mode] = new_mode.to_sym
    end
    def self.mode
      @@paypal_config[:mode] ||= :sandbox
    end
    
    def self.ipn_url
      ipn_urls[mode]
    end
    
    def self.ipn_validation_path
      URI.parse(ipn_url).path + "?cmd=_notify-validate"
    end

    def self.ipn_validation_url
      "#{ipn_url}?cmd=_notify-validate"
    end

    def self.paypal_sandbox_cert=(new_cert)
      @@paypal_config[:paypal_sandbox_cert] = new_cert
    end
    def self.paypal_sandbox_cert
      @@paypal_config[:paypal_sandbox_cert] ||= File.read(File.join(File.dirname(__FILE__), 'certs', 'paypal_sandbox.pem'))
    end

    def self.paypal_production_cert=(new_cert)
      @@paypal_config[:paypal_production_cert] = new_cert
    end
    def self.paypal_production_cert
      @@paypal_config[:paypal_production_cert]
    end

    def self.paypal_cert
      case mode
      when :sandbox
        paypal_sandbox_cert
      when :production
        raise StandardError.new("You should set Paypal::Config.paypal_production_cert with your paypal production certificate") unless paypal_production_cert
        paypal_production_cert
      end
    end
  end
end
