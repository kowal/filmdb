# coding: utf-8

require 'logger'
require 'awesome_print'
require 'imdb'
require 'sidekiq'
require 'sidekiq-status'
require 'ruby-progressbar'
require 'redis'
require 'json'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes
  end
end

module FilmdDb
  require 'filmdb/version'
  require 'filmdb/config'

  require 'filmdb/html_page'
  require 'filmdb/search/filmweb_service'

  require 'filmdb/search/filmweb'
  require 'filmdb/search/imdb'
  require 'filmdb/source/chomikuj'

  require 'filmdb/strategy/base'
  require 'filmdb/strategy/simple'
  require 'filmdb/strategy/background'

  require 'filmdb/report'
  require 'filmdb/workers/web_search_worker'

  require 'filmdb/background_job'

  require 'filmdb/cli/options'
  require 'filmdb/cli/table_reporter'
  require 'filmdb/cli/progressbar'
  require 'filmdb/cli/app'
end

FilmDb.configure do |config|
  config.logger = Logger.new(STDOUT).tap do |log|
    log.level = Logger::WARN
  end

  config.register_source 'http://chomikuj.pl', FilmDb::Source::Chomikuj

  config.register_strategy :default,    FilmDb::Strategy::Simple
  config.register_strategy :background, FilmDb::Strategy::Background

  config.register_service :filmweb, FilmDb::Search::Filmweb
  config.register_service :imdb,    FilmDb::Search::IMDB
end
