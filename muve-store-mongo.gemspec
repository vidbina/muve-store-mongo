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
end
