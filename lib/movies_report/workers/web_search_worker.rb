# coding: utf-8

require 'awesome_print'
require 'imdb'
require 'movies_report/config'
require 'movies_report/search/filmweb'
require 'movies_report/search/imdb'
require 'sidekiq'
require 'sidekiq-status'

MoviesReport.configure do |config|
  config.register_service :filmweb, MoviesReport::Search::Filmweb
  config.register_service :imdb, MoviesReport::Search::IMDB
end

module MoviesReport

  # Sidekiq worker class, which can
  # - schedule job for fetching movie stats in given movies service
  # - provide way to read status of given job
  #
  # @example Create job, returs job_id
  #   WebSearchWorker.perform_async('Rocky II', :filmweb)
  #   # => '1234'
  #
  # @example Read current status
  #   data = MoviesReport::WebSearchWorker.get_worker_data('1234')
  #   # => { 'title' => ... , 'state' => .. , [...] }
  #
  class WebSearchWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    sidekiq_options 'retry' => 'false'

    def perform(title, service)
      return if retrieve(:rating)

      store state: 'started'
      logger.debug { "[Job] : '#{title}'" }
      search_result = MoviesReport.services[service.to_sym].new(title)

      store title: title
      store rating: search_result.rating
      store state: 'finished'
      logger.debug { "[Job] : '#{title}' => '#{search_result.rating}'" }
      true
    end

    def self.get_worker_data(worker_id)
      Sidekiq::Status::get_all(worker_id)
    end

  end
end