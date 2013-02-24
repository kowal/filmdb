require "movies_report/version"
require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"
require "imdb"

module MoviesReport

  module FetchDocument
    def fetch_document(uri)
      Nokogiri::HTML(Net::HTTP.get_response(uri).body)
    end
  end

  module Movie

    class Chomikuj

      attr_reader :title, :size

      def initialize(title, size=nil)
        @title = title
        @size = size
      end

      class << self

        TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG
          lektor Lektor lekyor .napisy
          -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
          .pl PL ivo
          chomikuj Chomikuj.avi .avi dubbing.pl.avi
        }

        def sanitize_title(el)
          el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
        end

        def each_movie(document, &block)
          document.css('#FilesListContainer .fileItemContainer').map do |el|

            title = sanitize_title(el.css('.filename').first)
            size = el.css('.fileinfo li:nth-last-child(2)').first.content

            yield(self.new(title, size))
          end
        end

      end
    end
  end

  class Report
    include FetchDocument

    def initialize(movies_url)
      @movies_url = movies_url
      @movies_uri = URI(@movies_url)
      @movies_doc = fetch_document(@movies_uri)
      @engine     = Movie::Chomikuj # @todo: inject
    end

    def run!
      @engine.each_movie(@movies_doc) do |movie|
        title = movie.title
        ratings = build_rankings(title)

        ap "=> #{title} (#{ratings}) [#{movie.size}]"

        { title: title, ratings: ratings }
      end
    end

    def build_rankings(title)
      ratings = {}
      ratings[:filmweb] = Search::Filmweb.new(title).rating
      ratings[:imdb] = Search::IMDB.new(title).rating
      ratings
    end
  end

  module Search

    class BaseSearch
      include FetchDocument

      def initialize(title)
        @title = title
        @results = read_results
      end
    end

    # use the gem
    class IMDB < BaseSearch

      def rating
        movie = @results.first
        movie.rating if movie
      end

      def read_results
        Imdb::Search.new(@title).movies
      end

    end

    class Filmweb < BaseSearch

      SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

      # fetch ratings from 1st result:
      def rating
        movie_details_doc = fetch_document(URI(@results.first[:url]))
        el = movie_details_doc.css(".filmRating *[rel='v:rating']").first
        el.content.strip.gsub(',', '.').to_f if el
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
