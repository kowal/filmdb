# coding: utf-8

require 'terminal-table'

module MoviesReport

  class ConsoleReporter
    def initialize(movies_stats, options={})
      @colorize = options.fetch(:colorize) { true }

      @movies_stats = movies_stats
    end

    def display
      puts table_structure
    end

    def table_structure
      rows = @movies_stats.map { |movie| display_movie_stats(movie) }

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
        if valid_rating?(rating)
          table_cell(ranking_color(rating))
        else
          table_cell('-')
        end
      end
    end

    def valid_rating?(rating)
      Float(rating) rescue false
    end

    def table_cell(value)
      { value: value, alignment: :center }
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