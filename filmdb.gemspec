# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'filmdb/version'

Gem::Specification.new do |gem|
  gem.name          = "filmdb"
  gem.version       = FilmDb::VERSION
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
  gem.add_dependency "imdb"
  gem.add_dependency "awesome_print", [">= 1.1.0"]
  gem.add_dependency "terminal-table"
  gem.add_dependency "redis"
  gem.add_dependency "sidekiq"
  gem.add_dependency "sidekiq-status"
  gem.add_dependency "ruby-progressbar"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-collection_matchers"
  gem.add_development_dependency "rspec-legacy_formatters"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "libnotify"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock", ["< 1.14"]
  gem.add_development_dependency "fakeredis"
  gem.add_development_dependency "syntax"
  gem.add_development_dependency "rack"
  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "slim"
  gem.add_development_dependency "metric_fu"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "yield"
  gem.add_development_dependency "foreman"
end
