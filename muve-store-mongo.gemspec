# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muve-store-mongo/version'

Gem::Specification.new do |gem|
  gem.name          = "muve-store-mongo"
  gem.version       = Muve::Store::Mongo::VERSION
  gem.authors       = ["David Asabina"]
  gem.email         = ["david@supr.nu"]
  gem.description   = "The Mongo adaptor takes care of all the Mongo-related hassles while allowing you the trusty Muve interface"
  gem.summary       = "Mongo adaptor for the Muve engine"
  gem.homepage      = "https://github.com/vidbina/muve-store-mongo"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "muve", "~> 1.2.0-alpha.1"
  gem.add_runtime_dependency "mongo", "~> 1.10.2"

  gem.required_ruby_version = '>= 1.9.2'
end
