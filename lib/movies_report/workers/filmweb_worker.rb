# coding: utf-8

require 'awesome_print'
require 'movies_report/search/filmweb'
require 'sidekiq'
require 'sidekiq-status'

module MoviesReport

  class FilmwebWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(title)
      return if retrieve(:rating)

      ap "FilmwebWorker#perform(#{title})"
      search_result = MoviesReport::Search::Filmweb.new(title)

      store rating: search_result.rating
      ap "FilmwebWorker#perform Stored rating '#{search_result.rating}' for '#{title}'"
    end

  end
end