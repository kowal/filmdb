# coding: utf-8

require 'awesome_print'
require 'imdb'
require 'sidekiq'
require 'sidekiq-status'
require 'ruby-progressbar'

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

  require 'movies_report/report'
  require 'movies_report/workers/web_search_worker'

  require 'movies_report/console_reporter'
  require 'movies_report/background_job'
  require 'movies_report/cli'
  require 'movies_report/command_line_options'
end

MoviesReport.configure do |config|
  config.debug = false
end
