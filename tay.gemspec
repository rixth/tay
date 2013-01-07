# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tay/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Rix"]
  gem.email         = ["tom@rixth.org"]
  gem.summary       = %q{Tay helps you develop Chrome extensions}
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/rixth/tay"

  gem.files         = `git ls-files`.split($\)
  gem.files        += Dir['lib/tay/cli/generators/templates/**/*.html']
  gem.files        += Dir['lib/tay/cli/generators/templates/**/*.js']

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tay"
  gem.require_paths = ["lib"]
  gem.version       = Tay::VERSION

  gem.add_dependency 'bundler', '~> 1.2.3'
  gem.add_dependency 'thor', '~> 0.15.2'
  gem.add_dependency 'tilt', '~> 1.3.3'
  gem.add_dependency 'sprockets', '~> 2.4.3'
  gem.add_dependency 'crxmake', '~> 2.0.7'

  gem.add_development_dependency 'rspec', '~> 2.12'
  gem.add_development_dependency 'sdoc', '~> 0.3.20'
  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'coffee-script', '~> 2.2.0'
  gem.add_development_dependency 'haml', '~> 3.1.7'
end
