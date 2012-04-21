# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tnnl/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['David Stamm']
  gem.email         = ['whylom@gmail.com']
  gem.description   = %q{A command-line utility for wrangling SSH tunnels.}
  gem.summary       = %q{Tnnl is a command-line utility for wrangling SSH tunnels.}
  gem.homepage      = 'https://github.com/whylom/tnnl'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'tnnl'
  gem.require_paths = ['lib']
  gem.version       = Tnnl::VERSION

  gem.add_dependency 'net-ssh', '~> 2.3.0'
end
