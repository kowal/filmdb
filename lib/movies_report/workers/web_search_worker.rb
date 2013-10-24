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

      store rating: search_result.rating
      ap "[WebSearchWorker] Stored rating '#{search_result.rating}' for '#{title}'"
    end

    # def self.find_job(job_id)
    #   Sidekiq::Status::get_all job_id
    # end

  end
end