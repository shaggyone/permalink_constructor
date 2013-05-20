# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'permalink_constructor/version'

Gem::Specification.new do |gem|
  gem.name          = "permalink_constructor"
  gem.version       = PermalinkConstructor::VERSION
  gem.authors       = ["Victor Zagorski"]
  gem.email         = ["victor@zagorski.ru"]
  gem.summary       = %q{Automatic permalink generator.}
  gem.description   = %q{Automatically generates permalink from given attribute. Optionally adds numeric suffix, to maintan uniqueness inside of given scope.}
  gem.homepage      = "http://guthub.com/shaggyone/permalink_constructor"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
