# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tay/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Rix"]
  gem.email         = ["tom@rixth.org"]
  gem.summary       = %q{Tay helps you develop Chrome extensions}
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/rixth/tay"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tay"
  gem.require_paths = ["lib"]
  gem.version       = Tay::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sdoc'
  gem.add_development_dependency 'rake'
end
