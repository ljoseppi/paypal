require File.dirname(__FILE__) + '/spec_helper'

describe Paypal::Config do
  describe "mode" do
    it "should be :sandbox by default" do
      Paypal::Config.mode.should eql(:sandbox)
    end
    
    it "should accept :sandbox" do
      lambda {
        Paypal::Config.mode = :sandbox
      }.should_not raise_error
    end

    it "should accept :production" do
      lambda {
        Paypal::Config.mode = :production
      }.should_not raise_error
    end

    it "should not accept something different than :production or :sandbox" do
      lambda {
        Paypal::Config.mode = :demo
      }.should raise_error(ArgumentError)
    end
  end
  
  describe "when setting mode to sandbox" do
    before do
      Paypal::Config.mode = :sandbox
    end
    
    it "should be in :sandbox mode" do
      Paypal::Config.mode.should eql(:sandbox)
    end

    it "should have ipn url for sandbox" do
      Paypal::Config.ipn_url.should eql("https://www.sandbox.paypal.com/cgi-bin/webscr")
    end
    
    it "should have the ipn validation path for sandbox" do
      Paypal::Config.ipn_validation_path.should eql("/cgi-bin/webscr?cmd=_notify-validate")
    end

    it "should have the ipn validation url for sandbox" do
      Paypal::Config.ipn_validation_url.should eql("https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate")
    end
    
    it "should have paypal cert for sandbox" do
      Paypal::Config.paypal_cert.should eql(
"""-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----""")
    end
    
    it "should allow setting a new sandbox cert" do
      lambda {
        Paypal::Config.paypal_sandbox_cert = "TEST"
      }.should_not raise_error
      Paypal::Config.paypal_cert.should eql("TEST")
    end
  end
  
  describe "when setting mode to :production" do
    before do
      Paypal::Config.mode = :production
    end
    
    it "should be in :production mode" do
      Paypal::Config.mode.should eql(:production)
    end

    it "should have ipn url for production" do
      Paypal::Config.ipn_url.should eql("https://www.paypal.com/cgi-bin/webscr")
    end
    
    it "should have the ipn validation path for production" do
      Paypal::Config.ipn_validation_path.should eql("/cgi-bin/webscr?cmd=_notify-validate")
    end

    it "should have the ipn validation url for production" do
      Paypal::Config.ipn_validation_url.should eql("https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate")
    end

    describe "when paypal_production_cert was not set" do
      before do
        @old_cert, Paypal::Config.paypal_production_cert = Paypal::Config.paypal_production_cert, nil
      end
      
      after do
        Paypal::Config.paypal_production_cert = @old_cert
      end
      
      it "should raise an error" do
        lambda {
          Paypal::Config.paypal_cert
        }.should raise_error(StandardError)
      end
    end

    describe "when paypal_production_cert was set" do
      before do
        @old_cert, Paypal::Config.paypal_production_cert = Paypal::Config.paypal_production_cert, "TEST"
      end
      
      after do
        Paypal::Config.paypal_production_cert = @old_cert
      end
      
      it "should not raise an error" do
        lambda {
          Paypal::Config.paypal_cert
        }.should_not raise_error(StandardError)
      end

      it "should use the paypal production certificate" do
        Paypal::Config.paypal_cert.should eql("TEST")
      end
    end

    it "should allow setting a new production cert" do
      lambda {
        Paypal::Config.paypal_production_cert = "TEST"
      }.should_not raise_error
      Paypal::Config.paypal_cert.should eql("TEST")
    end
  end
end