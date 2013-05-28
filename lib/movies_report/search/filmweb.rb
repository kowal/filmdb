module MoviesReport

  module Search

    # Represents movie search in Filmweb service
    #
    class Filmweb < BaseSearch

      SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

      # fetch ratings from 1st result:
      def rating
        return '' unless @results.first

        format_rating(@results.first[:rating])
      end

      def filmweb_search_url
        URI(SEARCH_MOVIE_URL % CGI::escape(@title))
      end

      # @return [ [title, url], ... ]
      def read_results
        doc = HtmlPage.new(filmweb_search_url).document

        each_search_result(doc) do |el|
          { rating: el.content.strip }
        end
      end

      def each_search_result(document, &block)
        return unless document
        document.css(".resultsList .rateInfo strong").map do |el|
          yield(el)
        end
      end

      private

      # "7,1/10" => "7.1"
      def format_rating(rating)
        rating.gsub(/\/.*/, '').gsub(',','.').to_f rescue ''
      end
    end

  end

end