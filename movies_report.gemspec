# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
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

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "nokogiri"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"
end
