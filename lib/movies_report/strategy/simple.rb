# coding: utf-8

module MoviesReport

  module Strategy

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