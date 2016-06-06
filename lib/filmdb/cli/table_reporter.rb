# coding: utf-8

require 'terminal-table'

module FilmDb
  module Cli
    # Prints movie stats as table in terminal.
    #
    class TableReporter
      def initialize(movies_stats, options = {})
        @colorize     = options.fetch(:colorize) { true }
        @movies_stats = movies_stats
      end

      def display
        $stdout.puts table_structure
      end

      def table_structure
        rows = @movies_stats.map { |movie| display_movie_stats(movie) }

        Terminal::Table.new title:    'Movies stats',
                            headings: movies_stats_header,
                            rows:     rows
      end

      def movies_stats_header
        %w( Title Filmweb Imdb Avg )
      end

      def display_movie_stats(movie)
        [
          movie[:title],
          movie_ratings_columns(movie[:ratings]),
          average_rating(movie[:ratings])
        ].flatten
      end

      def movie_ratings_columns(ratings)
        ratings.map do |_service, rating|
          rating_cell(rating)
        end
      end

      def average_rating(ratings)
        total = ratings.values.compact
                       .reduce { |sum, el| sum + el }.to_f
        rating_cell(total / ratings.size)
      end

      def valid_rating?(rating)
        Float(rating)
      rescue
        false
      end

      def rating_cell(rating)
        display_value = if valid_rating?(rating)
                          ranking_color(rating)
                        else
                          '-'
        end
        { value: display_value, alignment: :center }
      end

      private

      def ranking_color(ranking)
        return ranking unless @colorize

        if ranking.to_f > 7.7
          colorize(32, ranking)
        elsif ranking.to_f > 6.7
          colorize(33, ranking)
        else
          colorize(37, ranking)
        end
      end

      def colorize(color_code, str)
        "\e[#{color_code}m#{str}\e[0m"
      end
    end
  end
end
