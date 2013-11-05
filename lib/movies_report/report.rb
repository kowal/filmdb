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
        results[:ratings][service_key] = each_film(title, service, service_key)
      end
      results
    end
  end

  class SimpleStrategy < BaseStrategy

    def each_film(title, service, service_key)
      track_progress { service.new(title).rating }
    end

    def track_progress(&block)
      print '.'
      $stdout.flush
      block.call
    end
  end

  class BackgroundStrategy < BaseStrategy

    # @retutn [String] worker_id ID which fetches info for given title
    def each_film(title, service, service_key)
      MoviesReport::WebSearchWorker.perform_async(title, service_key)
    end

    # @return [Hash] hash with current results
    def current_result(workers_ids)
      results = {}
      stats = { started: 0, finished: 0 }
      workers_ids.each do |worker_id|
        data = MoviesReport::WebSearchWorker.get_worker_data(worker_id)

        return {} unless data['state']

        stats[data['state'].to_sym] += 1

        results[data['title']] ||= []
        if data['rating'] && data['rating'] != '' && data['rating'] != '0.0'
          results[data['title']] << Float(data['rating'])
        end
      end
      hash_results = { status: stats }
      results.map do |title, ratings|
        hash_results[title] = ratings.compact.inject{ |sum, el| sum + el }.to_f / ratings.size
      end
      hash_results
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

    attr_reader :data, :strategy

    def initialize(report_options={})
      movies_url     = report_options.fetch(:url) { raise "url not given!" }
      @source_engine = report_options.fetch(:engine) { raise "engine not given!" }
      @movies_uri    = URI(movies_url)
      @data = []
    end

    def build!(strategy_name=:default)
      @strategy = select_strategy(strategy_name)
      MoviesReport.logger.info "Building report (#{strategy_name}) .."
      @movies_source = @source_engine.new(@movies_uri)
      @data = @strategy.run(extracted_movie_list)
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