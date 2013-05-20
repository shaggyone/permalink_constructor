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
  gem.description   = %q{Automatically generates permalink from given attribute. Optionally adds numeric suffix, to maintan uniqueness inside of given scope. Cyrillic text transliteration included.}
  gem.homepage      = "http://guthub.com/shaggyone/permalink_constructor"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activerecord',  '~> 3.2.11'
  gem.add_dependency 'activesupport', '~> 3.2.11'
  gem.add_dependency 'russian', '~> 0.6.0'

  gem.add_development_dependency 'rspec-core', '~> 2.12.2'
  gem.add_development_dependency 'rspec-expectations', '~> 2.12.1'
  gem.add_development_dependency 'rspec-mocks', '~> 2.12.2'

  gem.add_development_dependency 'shoulda', '~> 3.3.2'
  gem.add_development_dependency 'shoulda-context', '~> 1.0.2'
  gem.add_development_dependency 'shoulda-matchers', '~> 1.4.2'
end
