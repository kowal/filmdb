# coding: utf-8

require 'awesome_print'
require 'imdb'
require 'movies_report/search/filmweb'
require 'movies_report/search/imdb'
require 'sidekiq'
require 'sidekiq-status'

module MoviesReport

  class WebSearchWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    sidekiq_options 'retry' => 'false'

    SERVICES = {
      filmweb: MoviesReport::Search::Filmweb,
      imdb:    MoviesReport::Search::IMDB
    }

    def perform(title, service)
      return if retrieve(:rating)

      store state: 'started'
      logger.debug { "[Job] : '#{title}'" }
      search_result = SERVICES[service.to_sym].new(title)

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