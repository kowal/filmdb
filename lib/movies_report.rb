require "movies_report/version"
require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"

module MoviesReport

  module FetchDocument
    def fetch_document(uri)
      Nokogiri::HTML(Net::HTTP.get_response(uri).body)
    end
  end

  class Report
    include FetchDocument

    TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG
      lektor Lektor lekyor .napisy
      -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
      .pl PL ivo
      chomikuj Chomikuj.avi .avi dubbing.pl.avi
    }

    def initialize(movies_url)
      @movies_url = movies_url
      @movies_uri = URI(@movies_url)
      @movies_doc = fetch_document(@movies_uri)
    end

    def run!
      each_movie_title(@movies_doc) do |el|
        title = sanitize_movie_title(el)
        ratings = Search::Filmweb.new(title).ratings

        # ap [ title, ratings ]

        { title: title, ratings: ratings }
      end
    end

    def sanitize_movie_title(el)
      el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
    end

    def each_movie_title(document, &block)
      document.css('#FilesListContainer .fileItemContainer .filename').map do |el|
        yield(el)
      end
    end
  end

  module Search
    class Filmweb
      include FetchDocument

      SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

      def initialize(title)
        @title = title
        @results = read_results
      end

      # fetch ratings from 1st result:
      def ratings
        movie_details_doc = fetch_document(URI(@results.first[:url]))
        el = movie_details_doc.css(".filmRating *[rel='v:rating']").first
        el.content if el
      end

      # @return [ [title, url], ... ]
      def read_results
        uri = URI(SEARCH_MOVIE_URL % CGI::escape(@title))
        doc = fetch_document(uri)

        each_search_result(doc) do |el|
          { title: el.content.strip, url: "http://#{uri.host}#{el.attr('href')}" }
        end
      end

      def each_search_result(document, &block)
        document.css('.searchResult a.searchResultTitle').map do |el|
          yield(el)
        end
      end
    end
  end

  class DSL
    def self.parse_html(url)
      Report.new(url).run!
    end
  end
end
