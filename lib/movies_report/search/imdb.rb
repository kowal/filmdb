# coding: utf-8

module MoviesReport

  module Search

    # Represents movie search in IMDB service
    #
    class IMDB < BaseSearch

      def rating
        movie = @results.first
        movie.rating if movie
      end

      def read_results
        Imdb::Search.new(@title).movies
      rescue => e
        ap "Can fetch IMDB results for #{@title}"
        ap e.message
        []
      end

    end

  end

end