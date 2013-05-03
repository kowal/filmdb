module MoviesReport

  module Search

    # Base class for all html-page based searchers
    # - takes movie title to search for
    # - searches immediately when instance is created
    # - {read_results} must be implemented in concrete classes
    #
    class BaseSearch

      attr_reader :title

      def initialize(title)
        @title = title
        @results = read_results
      end

      def read_results
        raise NotImplementedError,
              'This is an abstract base method. Implement in your subclass.'
      end
    end

  end
end