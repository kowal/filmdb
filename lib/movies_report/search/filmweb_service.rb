# coding: utf-8

module MoviesReport

  module Search

    # Knows how to fetch content from Filmweb for a given movie title.
    #
    class FilmwebService

      class << self

        def find(title)
          document = html_document_for(title)
          ap "document #{document.class.name}"

          if document
            result = search_results(document)[0]
            ap "result #{result}"

            { rating: result ? result.content.strip : '' }
          end
        end

        def search_results(document)
          document.css(RATE_INFO_SELECTOR)
        end

        private

        def html_document_for(title)
          ap "find #{filmweb_search_url(title)}"
          HtmlPage.new(filmweb_search_url(title)).document
        end

        SEARCH_MOVIE_URL = 'http://www.filmweb.pl/search?q=%s'

        RATE_INFO_SELECTOR = '.resultsList .rateInfo strong'

        def filmweb_search_url(title)
          URI(SEARCH_MOVIE_URL % CGI.escape(title))
        end

      end

    end

  end

end