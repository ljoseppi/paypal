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

    describe "with :business_key, :business_cert and :business_certid params filled" do
      before do
        @result = paypal_setup(1, "10.00", "trash@openhood.com", {
         :business_key => File.read(File.join(File.dirname(__FILE__), "../fixtures/business_key.pem")),
         :business_cert => File.read(File.join(File.dirname(__FILE__), "../fixtures/business_cert.pem")),
         :business_certid => "CERTID"
        })
      end

      it "should include cmd with _s-xclick" do
        @result.should have_css("input[type=hidden][name=cmd][value=_s-xclick]")
      end
      it "should include cmd with encrypted datas" do
        @result.should have_css("input[type=hidden][name=cmd][value*=PKCS7]")
      end
    end

    describe "with unknown optios" do
      it "should raise an error" do
        lambda do
          paypal_setup(1, "10.00", "trash@openhood.com", :unknown_option => "unknown")
        end.should raise_error(ArgumentError, "Unknown option #{[:unknown_option].inspect}")
      end
    end
  end
end