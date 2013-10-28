# coding: utf-8

if ENV['TRAVIS'] == 'true'
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'movies_report'
require 'vcr'


# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = 'random'
  config.mock_framework = :mocha
  config.project_tracker_url = 'https://mkowalcze.kanbanery.com/projects/32672/board/tasks/%s'
end

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

def expected_results_for_site(site)
  YAML::load(File.open("fixtures/expected/#{site}.yml"))
end

Sidekiq::Logging.logger = nil
