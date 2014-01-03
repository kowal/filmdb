# coding: utf-8

require 'logger'
require 'awesome_print'
require 'imdb'
require 'sidekiq'
require 'sidekiq-status'
require 'ruby-progressbar'
require 'redis'
require "json"

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

module MoviesReport

  require 'movies_report/version'
  require 'movies_report/config'

  require 'movies_report/html_page'
  require 'movies_report/search/filmweb_service'

  require 'movies_report/search/filmweb'
  require 'movies_report/search/imdb'
  require 'movies_report/source/chomikuj'

  require 'movies_report/strategy/base'
  require 'movies_report/strategy/simple'
  require 'movies_report/strategy/background'

  require 'movies_report/report'
  require 'movies_report/workers/web_search_worker'

  require 'movies_report/background_job'

  require 'movies_report/cli/options'
  require 'movies_report/cli/table_reporter'
  require 'movies_report/cli/progressbar'
  require 'movies_report/cli/app'
end

MoviesReport.configure do |config|
  config.logger = Logger.new(STDOUT).tap do |log|
    log.level = Logger::WARN
  end

  config.register_source 'http://chomikuj.pl', MoviesReport::Source::Chomikuj

  config.register_strategy :default,    MoviesReport::Strategy::Simple
  config.register_strategy :background, MoviesReport::Strategy::Background

  config.register_service :filmweb, MoviesReport::Search::Filmweb
  config.register_service :imdb,    MoviesReport::Search::IMDB
end
