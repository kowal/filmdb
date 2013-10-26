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

    SERVICES = {
      filmweb: MoviesReport::Search::Filmweb,
      imdb:    MoviesReport::Search::IMDB
    }

    def perform(title, service)
      return if retrieve(:rating)

      ap "[WebSearchWorker] '#{title}'"
      search_result = SERVICES[service.to_sym].new(title)

      store title: title
      store rating: search_result.rating
      ap "[WebSearchWorker] Stored rating '#{search_result.rating}' for '#{title}'"
      nil
    end

  end
end