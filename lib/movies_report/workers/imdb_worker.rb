# coding: utf-8

require 'awesome_print'
require 'imdb'
require 'movies_report/search/imdb'
require 'sidekiq'
require 'sidekiq-status'

module MoviesReport

  class ImdbWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(title)
      return if retrieve(:rating)

      ap "[ImdbWorker] '#{title}'"
      search_result = MoviesReport::Search::IMDB.new(title)

      store rating: search_result.rating
      ap "[ImdbWorker] Stored rating '#{search_result.rating}' for '#{title}'"
    end

    def self.find_job(job_id)
      Sidekiq::Status::get_all job_id
    end

  end
end