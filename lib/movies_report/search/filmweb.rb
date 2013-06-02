# coding: utf-8

module MoviesReport

  module Search

    # Represents movie search in Filmweb service
    #
    class Filmweb

      def initialize(title, service=FilmwebService)
        @title = title
        @result = service.find(title)
      end

      # fetch ratings from 1st result:
      def rating
        format_rating(@result[:rating])
      end

      private

      # "7,1/10" => "7.1"
      def format_rating(rating)
        rating.gsub(/\/.*/, '').gsub(',', '.').to_f rescue ''
      end
    end

  end

end