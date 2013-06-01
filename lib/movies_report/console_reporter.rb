module MoviesReport

  class ConsoleReporter
    def initialize(movies_report)
      @movies_report = movies_report
    end

    def display
      display_header

      @movies_report.each do |movie|
        display_movie_stats(movie) if movie_has_stats?(movie)
      end
    end

    def display_header
      printf "%-60s %s %s\n", 'Title', 'Filmweb', 'Imdb'
    end

    def display_movie_stats(movie)
      printf "* %-60s %s     %s\n", movie[:title], ranking_color(movie[:ratings][:filmweb]), ranking_color(movie[:ratings][:imdb])
    end

    def movie_has_stats?(movie)
      [movie[:ratings][:filmweb], movie[:ratings][:imdb]].any? do |r|
        !r.nil? && !r.to_s.empty?
      end
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