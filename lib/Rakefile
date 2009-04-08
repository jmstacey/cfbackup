require 'rubygems'
gem 'echoe', '~> 3.0.1'
require 'echoe'
require './lib/cloudfiles.rb'
 
echoe = Echoe.new('cloudfiles') do |p|
  p.author = ["H. Wade Minter", "Rackspace Hosting"]
  p.email = 'wade.minter@rackspace.com'
  p.version = CloudFiles::VERSION
  p.summary = "A Ruby API into Mosso Cloud Files"
  p.description = 'A Ruby version of the Mosso Cloud Files API.'
  p.url = "http://www.mosso.com/cloudfiles.jsp"
  p.runtime_dependencies = ["mime-types >=1.0"]
end

desc 'Generate the .gemspec file in the root directory'
task :gemspec do
  File.open("#{echoe.name}.gemspec", "w") {|f| f << echoe.spec.to_ruby }
end
task :package => :gemspec

namespace :test do
  desc 'Check test coverage'
  task :coverage do
    rm_f "coverage"
    system("rcov -x '/Library/Ruby/Gems/1.8/gems/' --sort coverage #{File.join(File.dirname(__FILE__), 'test/*_test.rb')}")
    system("open #{File.join(File.dirname(__FILE__), 'coverage/index.html')}") if PLATFORM['darwin']
  end

  desc 'Remove coverage products'
  task :clobber_coverage do
    rm_r 'coverage' rescue nil
  end

end


