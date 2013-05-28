# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'movies_report/version'

Gem::Specification.new do |gem|
  gem.name          = "movies_report"
  gem.version       = MoviesReport::VERSION
  gem.authors       = ["Marek Kowalcze"]
  gem.email         = ["marek.kowalcze@gmail.com"]
  gem.description   = %q{Movie report tool.}
  gem.summary       = %q{Simple tool for building movie report from multiple sources.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri", [">= 1.3.3"]
  gem.add_dependency "imdb", [">= 0.6.8"]
  gem.add_dependency "awesome_print", [">= 1.1.0"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "libnotify"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock", ["= 1.9.3"]
  gem.add_development_dependency "syntax"
end
