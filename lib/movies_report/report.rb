# coding: utf-8

module MoviesReport

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
      MoviesReport.strategies[strategy].new
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