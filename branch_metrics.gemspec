# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'branch_metrics/version'

Gem::Specification.new do |gem|
  gem.name          = "branch_metrics"
  gem.version       = Branch::VERSION
  gem.authors       = ["Austin Hay"]
  gem.email         = [""]
  gem.description   = ["A simple way to pass data & gather insight through user app install using deep linking."]
  gem.summary       = ["A simple way to pass data & gather insight through user app install using deep linking."]
  gem.homepage      = "https://branch.io/docs/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  # Gems that must be intalled for sift to compile and build
  gem.add_development_dependency "rspec", "~> 2.12"
  gem.add_development_dependency "fakeweb", "~> 1.3.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'simplecov', '~> 0.7.1'

  # Gems that must be installed for sift to work
  gem.add_dependency "httparty", ">= 0.8.3"
  gem.add_dependency "multi_json", ">= 1.3.4"
  gem.add_dependency "hashie", ">= 1.2.0"
end
