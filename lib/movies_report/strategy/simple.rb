# coding: utf-8

module MoviesReport

  module Strategy

    # Defualt strategy for fetching movies stats from service.
    # - simply delegates to service for each movie
    # - prints progress to std output (dots)
    #
    class Simple < Base

      def each_film(title, service, service_key)
        track_progress { service.new(title).rating }
      end

      def track_progress(&block)
        print '.'
        $stdout.flush
        block.call
      end
    end

  end

end