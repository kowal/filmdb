# coding: utf-8

module MoviesReport

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    attr_reader :data, :strategy

    def initialize(report_options={})
      movies_url     = report_options.fetch(:url)    { raise ArgumentError.new("url not given!") }
      @source_engine = report_options.fetch(:engine) { raise ArgumentError.new("engine not given!") }
      @movies_uri    = URI(movies_url)
      @data = []
    end

    def build!(strategy_name=:default)
      @strategy = select_strategy(strategy_name)
      MoviesReport.logger.info "Building report (#{strategy_name}) .."
      @movies_source = @source_engine.new(@movies_uri)
      movies_results = extract_movie_list
      if movies_results
        @data = @strategy.run(movies_results)
      end
    end

    def select_strategy(strategy)
      MoviesReport.strategies[strategy].new
    end

    def workers_ids
      all_ratings
    end

    private

    def extract_movie_list
      @movies_source.all_movies { |movie| movie[:title] if movie }
    end

    def all_ratings
      @data.map { |movie| movie[:ratings].values }.flatten
    end

  end

end