# coding: utf-8

require 'terminal-table'

module MoviesReport

  class ConsoleReporter
    def initialize(movies_report, options={})
      @colorize = options.fetch(:colorize) { true }

      @movies_report = movies_report
    end

    def display
      puts table_structure
    end

    def table_structure
      rows = @movies_report.map { |movie| display_movie_stats(movie) }

      Terminal::Table.new title:    "Movies stats",
                          headings: movies_stats_header,
                          rows:     rows
    end

    def movies_stats_header
      %w{ Title Filmweb Imdb }
    end

    def display_movie_stats(movie)
      [
        movie[:title],
        movie_ratings_columns(movie[:ratings])
      ].flatten
    end

    def movie_ratings_columns(ratings)
      ratings.map do |service, rating|
        if invalid_rating?(rating)
          table_cell('-')
        else
          table_cell(ranking_color(rating))
        end
      end
    end

    def invalid_rating?(rating)
      !rating || rating.empty? || !rating.respond_to?(:to_f)
    end

    def table_cell(value)
      { value: value, alignment: :center }
    end

    private

    def ranking_color(ranking)
      return ranking unless @colorize

      if ranking.to_f > 7.5
        colorize(32, ranking)
      elsif ranking.to_f > 6.0
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