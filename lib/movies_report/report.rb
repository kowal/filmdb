# coding: utf-8

module MoviesReport

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    attr_reader :data

    def initialize(report_options={})
      movies_url    = report_options.fetch(:url) { raise "url not given!" }
      source_engine = report_options.fetch(:engine) { "engine not given!" }
      @work_in_background = report_options.fetch(:background) { false }

      @movies_uri    = URI(movies_url)
      @movies_source = source_engine.new(@movies_uri)
      @data = []
    end

    def build!
      _movies = movies_collection
      ap "Building report for #{_movies.size} movies. This can take some time ..."
      @data = _movies.map do |movie|
        { title:   movie[:title],
          ratings: build_rankings(movie[:title]) }
      end
    end

    def movies_collection
      @movies_source.all_movies.uniq { |movie| movie[:title] }
    end

    def build_rankings(title)
      { filmweb: filmweb_rating(title),
        imdb:    imdb_rating(title) }
    end

    def read_rankings
      MoviesReport::FilmwebWorker.find_job(job_id)
    end

    def all_ratings
      @data.map { |movie| movie[:ratings].values }.flatten
    end

    private

    def filmweb_rating(title)
      if @work_in_background
        MoviesReport::WebSearchWorker.perform_async(title, :filmweb)
      else
        get_rating { MoviesReport::Search::Filmweb.new(title).rating }
      end
    end

    def imdb_rating(title)
      if @work_in_background
        MoviesReport::WebSearchWorker.perform_async(title, :imdb)
      else
        get_rating { MoviesReport::Search::IMDB.new(title).rating }
      end
    end

    def get_rating(&block)
      print '.'
      $stdout.flush
      block.call
    end

  end

end