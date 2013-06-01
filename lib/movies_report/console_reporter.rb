# coding: utf-8

require 'terminal-table'

module MoviesReport

  class ConsoleReporter
    def initialize(movies_report)
      @movies_report = movies_report
    end

    def display

      rows = @movies_report.map do |movie|
        display_movie_stats(movie)
      end

      table = Terminal::Table.new title:    "Movies stats",
                                  headings: movies_stats_header,
                                  rows:     rows

      puts table
    end

    def movies_stats_header
      %w{ Title Filmweb Imdb }
    end

    def display_movie_stats(movie)
      [ movie[:title],
        ranking_color(movie[:ratings][:filmweb] || '-'),
        ranking_color(movie[:ratings][:imdb] || '-') ]
    end

    private

    def ranking_color(ranking)
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