# coding: utf-8

if ENV['TRAVIS'] == 'true'
  require 'coveralls'
  Coveralls.wear!
else
  unless RUBY_PLATFORM == 'java'
    require 'simplecov'
    SimpleCov.start
  end
end

require 'fakeredis'
require 'movies_report'
require 'vcr'

require 'rspec/collection_matchers'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
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

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

Sidekiq::Logging.logger = nil
