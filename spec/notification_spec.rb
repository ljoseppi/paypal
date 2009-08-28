require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Paypal::Notification do
  before do
    Paypal::Config.mode = :sandbox
  end
  
  def valid_http_raw_data
    "mc_gross=500.00&address_status=confirmed&payer_id=EVMXCLDZJV77Q&tax=0.00&address_street=164+Waverley+Street&payment_date=15%3A23%3A54+Apr+15%2C+2005+PDT&payment_status=Completed&address_zip=K2P0V6&first_name=Tobias&mc_fee=15.05&address_country_code=CA&address_name=Tobias+Luetke&notify_version=1.7&custom=cusdata&payer_status=unverified&business=tobi%40leetsoft.com&address_country=Canada&address_city=Ottawa&quantity=1&payer_email=tobi%40snowdevil.ca&verify_sign=AEt48rmhLYtkZ9VzOGAtwL7rTGxUAoLNsuf7UewmX7UGvcyC3wfUmzJP&txn_id=6G996328CK404320L&payment_type=instant&last_name=Luetke&address_state=Ontario&receiver_email=tobi%40leetsoft.com&payment_fee=&receiver_id=UQ8PDYXJZQD9Y&txn_type=web_accept&item_name=Store+Purchase&mc_currency=CAD&item_number=&test_ipn=1&payment_gross=&shipping=0.00&invoice=myinvoice&pending_reason=mypending_reason&reason_code=myreason_code&memo=mymemo&payment_type=mypayment_type&exchange_rate=myexchange_rate"
  end

  def self.valid_parsed_raw_data
    {"payment_gross"=>"", "receiver_id"=>"UQ8PDYXJZQD9Y", "payer_email"=>"tobi@snowdevil.ca", "address_city"=>"Ottawa", "address_country"=>"Canada", "business"=>"tobi@leetsoft.com", "address_name"=>"Tobias Luetke", "payment_status"=>"Completed", "tax"=>"0.00", "reason_code"=>"myreason_code", "receiver_email"=>"tobi@leetsoft.com", "invoice"=>"myinvoice", "verify_sign"=>"AEt48rmhLYtkZ9VzOGAtwL7rTGxUAoLNsuf7UewmX7UGvcyC3wfUmzJP", "address_street"=>"164 Waverley Street", "memo"=>"mymemo", "mc_currency"=>"CAD", "txn_type"=>"web_accept", "quantity"=>"1", "address_zip"=>"K2P0V6", "pending_reason"=>"mypending_reason", "item_name"=>"Store Purchase", "txn_id"=>"6G996328CK404320L", "address_country_code"=>"CA", "payment_fee"=>"", "address_state"=>"Ontario", "payer_status"=>"unverified", "notify_version"=>"1.7", "shipping"=>"0.00", "mc_fee"=>"15.05", "payment_date"=>"15:23:54 Apr 15, 2005 PDT", "address_status"=>"confirmed", "test_ipn"=>"1", "payment_type"=>"mypayment_type", "first_name"=>"Tobias", "last_name"=>"Luetke", "payer_id"=>"EVMXCLDZJV77Q", "mc_gross"=>"500.00", "exchange_rate"=>"myexchange_rate", "item_number"=>"", "custom"=>"cusdata"}
  end
  
  describe "without data" do
    it "should raise Paypal::NoDataError" do
      lambda {
        Paypal::Notification.new(nil)
      }.should raise_error(Paypal::NoDataError)
    end
  end
  
  describe "with valid raw data" do
    before do
      @notification = Paypal::Notification.new(valid_http_raw_data)
    end

    it "should store raw data" do
      @notification.raw.should eql(valid_http_raw_data)
    end

    describe "#params" do
      it "should not be empty" do
        @notification.params.should_not be_empty
      end

      valid_parsed_raw_data.each do |key, value|
        it "should have #{key}=#{value}" do
          @notification.params[key].should eql(value)
        end
      end

      it "should have unescaped values" do
        @notification.params["payment_date"].should eql("15:23:54 Apr 15, 2005 PDT")
      end
      
      it "should include only the last value for duplicate key" do
        @notification.params["payment_type"].should eql("mypayment_type")
      end
    end

    it "should define method to access each query params" do
      self.class.valid_parsed_raw_data.each do |key, _|
        lambda {
          @notification.send(key.to_sym)
        }.should_not raise_error
      end
    end

    ["Canceled_Reversal",
    "Completed",
    "Denied",
    "Expired",
    "Failed",
    "Pending",
    "Processed",
    "Refunded",
    "Reversed",
    "Voided"].each do |status|
      describe "when transaction payment_status = '#{status}'" do
        it "should be #{status.downcase}" do
          old_status, @notification.params["payment_status"] = @notification.params["payment_status"], status
        
          @notification.send(:"#{status.downcase}?").should be_true
        
          @notification.params["payment_status"] = old_status
        end
      end
    end

    describe "#acknowledge" do
      before do
        @paypal_validation_url = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate"
      end
      
      it "should send a post request to Paypal at #{@paypal_validation_url}" do
        FakeWeb.register_uri(:post, @paypal_validation_url, :body => 'VERIFIED')
        
        lambda { @notification.acknowledge }.should_not raise_error(FakeWeb::NetConnectNotAllowedError)

        FakeWeb.clean_registry
      end
      
      describe "when Paypal response is VERIFIED" do
        before do
          FakeWeb.register_uri(:post, @paypal_validation_url, :body => 'VERIFIED')
        end

        it "should return true" do
          @notification.acknowledge.should be(true)
        end

        after do
          FakeWeb.clean_registry
        end
      end

      describe "when Paypal response is INVALID" do
        before do
          FakeWeb.register_uri(:post, @paypal_validation_url, :body => 'INVALID')
        end

        it "should return false" do
          @notification.acknowledge.should be(false)
        end

        after do
          FakeWeb.clean_registry
        end
      end

      describe "when Paypal response is not a recognize value" do
        before do
          FakeWeb.register_uri(:post, @paypal_validation_url, :body => 'BAD_VALUE')
        end

        it "should raise StandardError" do
          lambda {
            @notification.acknowledge
          }.should raise_error(StandardError)
        end
        
        it "should include body response in StandardError" do
          begin
            @notification.acknowledge
          rescue StandardError => e
            e.message.should =~ /BAD_VALUE/
          end
        end

        after do
          FakeWeb.clean_registry
        end
      end
    end
  end
end