require "spec_helper"

describe Paypal::Helpers::Common do
  include Paypal::Helpers::Common

  describe ".paypal_setup(item_number, amount, business, options = {})" do
    describe "with default options" do
      before do
        @result = paypal_setup(1, "10.00", "trash@openhood.com")
      end

      {
        "item_number" => "1",
        "amount" => "10.00",
        "currency_code" => "USD",
        "business" => "trash@openhood.com",
        "cmd" => "_xclick",
        "quantity" => "1",
        "item_number" => "1",
        "item_name" => "Store purchase",
        "no_shipping" => "1",
        "no_note" => "1",
        "charset" => "utf-8"
      }.each do |key, value|
        it "should include #{key} with #{value}" do
          @result.should have_css("input[type=hidden][name=\"#{key}\"][value=\"#{value}\"]")
        end
      end
    end

    describe "with :enable_encryption set to true" do
      context "with Paypal::Config.business_cert business_key and business_cert_id not set" do
        it "should raise an error" do
          lambda {
            paypal_setup(1, "10.00", "trash@openhood.com", {:enable_encryption => true})
          }.should raise_error ArgumentError, "Paypal::Config.business_key, Paypal::Config.business_cert and Paypal::Config.business_cert_id should be set if you use :enable_encryption"
        end
      end

      context "with Paypal::Config.business_cert business_key and business_cert_id set" do
        before do
          Paypal::Config.business_cert = File.read(File.expand_path("../../fixtures/business_cert.pem", __FILE__))
          Paypal::Config.business_key = File.read(File.expand_path("../../fixtures/business_key.pem", __FILE__))
          Paypal::Config.business_cert_id = "CERTID"
          @result = paypal_setup(1, "10.00", "trash@openhood.com", {
            :enable_encryption => true
          })
        end

        it "should include cmd with _s-xclick" do
          @result.should have_css("input[type=hidden][name=cmd][value=_s-xclick]")
        end
        it "should include cmd with encrypted datas" do
          @result.should have_css("input[type=hidden][name=encrypted][value*=PKCS7]")
          @result.should_not have_css("input[type=hidden][name=encrypted][value*='\n']")
        end
      end
    end

    describe "with unknown options" do
      it "should raise an error" do
        lambda do
          paypal_setup(1, "10.00", "trash@openhood.com", :unknown_option => "unknown")
        end.should raise_error(ArgumentError, "Unknown option #{[:unknown_option].inspect}")
      end
    end
  end
end