require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "paypal"
    gem.summary = %Q{Paypal Express Integration}
    gem.description = %Q{Integrate Paypal Express}
    gem.email = "jonathan@tron.name"
    gem.homepage = "http://github.com/JonathanTron/paypal"
    gem.authors = ["Jonathan Tron", "Joseph Halter", "Tobias Luetke"]
    gem.add_dependency "rack", ">= 1.0.0"
    gem.add_development_dependency "rspec", ">= 2.0.0.a"
    gem.add_development_dependency "rcov", ">= 0.9.8"
    gem.add_development_dependency "nokogiri"
    gem.add_development_dependency "bluecloth"
    gem.add_development_dependency "yard"
    gem.add_development_dependency "fakeweb"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rspec/core/rake_task'
::Rspec::Core::RakeTask.new(:spec)
::Rspec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = "--exclude spec/"
end
task :spec => :check_dependencies
task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
