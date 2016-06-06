# coding: utf-8

module FilmDb
  module Strategy
    # Defualt strategy for fetching movies stats from service.
    # - simply delegates to service for each movie
    # - prints progress to std output (dots)
    #
    class Simple < Base
      def each_film(title, service, _service_key)
        track_progress { service.new(title).rating }
      end

      def track_progress
        print '.'
        $stdout.flush
        yield
      end
    end
  end
end
