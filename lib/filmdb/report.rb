# coding: utf-8

module FilmDb
  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  # TODO: rename to FilmDB::Query
  #
  class Report
    class BuildError < StandardError; end

    attr_reader :results, :strategy, :movies_source

    # TODO: rename :engine -> movies_source
    #
    def initialize(report_options = {})
      movies_url     = report_options.fetch(:url) { raise ArgumentError, 'url not given!' }
      @movies_uri    = URI(movies_url)
      @source_engine = report_options.fetch(:engine) { select_source(@movies_uri) || raise_invalid_engine! }
      @movies_source = @source_engine.new(@movies_uri)
      @results = []
    end

    def build!(strategy_name = :default)
      FilmDb.logger.info "Building report (#{strategy_name}) .."

      @strategy = select_strategy(strategy_name)
      movies_results = extract_movie_list

      @results = @strategy.run(movies_results)

    rescue StandardError => ex
      raise BuildError, "Cant build report!. #{ex.message}"
    end

    def select_strategy(strategy)
      strategy_class = FilmDb.strategies[strategy] || (raise BuildError, "Strategy '#{strategy}' is not registered!")
      strategy_class.new
    end

    def select_source(movies_url)
      source_host = movies_url.hostname
      FilmDb.sources[source_host]
    end

    def workers_ids
      all_ratings
    end

    private

    def extract_movie_list
      @movies_source.all_movies { |movie| movie[:title] if movie }
    end

    def all_ratings
      @results.map { |movie| movie[:ratings].values }.flatten
    end

    def raise_invalid_engine!
      raise ArgumentError, "engine not given or not registered for current url (#{@movies_uri})"
    end
  end
end
