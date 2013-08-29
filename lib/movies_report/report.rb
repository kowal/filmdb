# coding: utf-8

module MoviesReport

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    def initialize(report_options={})
      movies_url    = report_options.fetch(:url) { raise "url not given!" }
      source_engine = report_options.fetch(:engine) { "engine not given!" }

      @movies_uri    = URI(movies_url)
      @movies_source = source_engine.new(@movies_uri)
    end

    def build!
      movies_info = []
      _movies = movies_collection
      _movies.map do |movie|
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

    private

    def filmweb_rating(title)
      MoviesReport::Search::Filmweb.new(title).rating
    end

    def imdb_rating(title)
      MoviesReport::Search::IMDB.new(title).rating
    end
  end

end