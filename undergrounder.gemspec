# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'undergrounder/version'

Gem::Specification.new do |gem|
  gem.name          = "undergrounder"
  gem.version       = Undergrounder::VERSION
  gem.authors       = ["Enzo Rivello"]
  gem.email         = ["vincenzo.rivello@gmail.com"]
  gem.description   = "Implementation of a short path finder for the London Tube"
  gem.summary       = ""
  gem.homepage      = ""

  gem.add_dependency "sinatra"
  gem.add_dependency "padrino"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "ruby-debug19"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
