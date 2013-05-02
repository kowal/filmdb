module MoviesReport

  # Report:
  # - takes movies data source class
  # - for each movie from data source, create rankings
  #
  class Report

    def initialize(movies_url, movies_source_engine)
      @movies_uri    = URI(movies_url)
      @movies_source = movies_source_engine.new(@movies_uri)
    end

    def build!
      @movies_source.each_movie do |movie|
        title    = movie[:title]
        rankings = build_rankings(title)

        ap "* #{title} [#{rankings.inspect}]" if MoviesReport.debug

        { title: title, ratings: rankings }
      end
    end

    def build_rankings(title)
      { filmweb: MoviesReport::Search::Filmweb.new(title).rating,
        imdb:    MoviesReport::Search::IMDB.new(title).rating }
    end
  end

end