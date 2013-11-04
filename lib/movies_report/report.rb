# coding: utf-8

module MoviesReport

  class BaseStrategy

    # @return [Array<Hash>]
    def run(movies)
      movies.map do |movie|
        { title: movie[:title] }.merge(movie_stats(movie[:title]))
      end
    end

    def movie_stats(title)
      results = { ratings: {} }
      MoviesReport::SERVICES.each do |service_key, service|
        # FilmDB.register_service :imdb, ::Service::IMDB
        # results[:ratings][:imdb] = [String|Hash]
        results[:ratings][service_key] = each_film_in_service(title, service, service_key)
      end
      results
    end
  end

  class SimpleStrategy < BaseStrategy

    def each_film_in_service(title, service, service_key)
      track_progress { service.new(title).rating }
    end

    def track_progress(&block)
      print '.'
      $stdout.flush
      block.call
    end
  end

  class BackgroundStrategy < BaseStrategy

    def each_film_in_service(title, service, service_key)
      MoviesReport::WebSearchWorker.perform_async(title, service_key)
    end

  end

  STRATEGIES = {
    default:    SimpleStrategy,
    background: BackgroundStrategy
  }

  SERVICES = {
    filmweb: MoviesReport::Search::Filmweb,
    imdb: MoviesReport::Search::IMDB
  }

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    attr_reader :data


    def initialize(report_options={})
      movies_url    = report_options.fetch(:url) { raise "url not given!" }
      source_engine = report_options.fetch(:engine) { "engine not given!" }

      @movies_uri    = URI(movies_url)
      @movies_source = source_engine.new(@movies_uri)
      @data = []
    end

    def build!(strategy=:default)
      @data = select_strategy(strategy).run(extracted_movie_list)
    end

    def select_strategy(strategy)
      MoviesReport::STRATEGIES[strategy].new
    end

    def extracted_movie_list
      @movies_source.all_movies.uniq { |movie| movie[:title] }
    end

    def workers_ids
      all_ratings
    end

    private

    def all_ratings
      @data.map { |movie| movie[:ratings].values }.flatten
    end

  end

end