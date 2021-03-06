$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "concerto_hardware/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "concerto_hardware"
  s.version     = ConcertoHardware::VERSION
  s.authors     = "Concerto Team"
  s.email       = ["team@concerto-signage.org"]
  s.homepage    = "http://concerto-signage.org"
  s.summary     = "A Rails Engine for managing Bandshell-powered Concerto hardware"
  s.description = "A Rails Engine for managing Bandshell-powered Concerto hardware"
  s.license = "Apache-2.0"
  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
end

