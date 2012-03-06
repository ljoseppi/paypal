# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paypal/version"

Gem::Specification.new do |s|
  s.name        = "ljoseppi-paypal"
  s.version     = Paypal::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lairton Borges","Jonathan TRON", "Joseph HALTER", "Tobias LUETKE"]
  s.email       = "ljoseppi@gmail.com"
  s.homepage    = "https://github.com/ljoseppi/paypal"
  s.summary     = %q{Integrate Paypal Express}
  s.description = %q{Paypal Express Integration}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])

  s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
  s.add_development_dependency(%q<rcov>, [">= 0.9.8"])
  s.add_development_dependency(%q<nokogiri>, [">= 0"])
  s.add_development_dependency(%q<bluecloth>, [">= 0"])
  s.add_development_dependency(%q<yard>, [">= 0"])
  s.add_development_dependency(%q<fakeweb>, [">= 0"])
end