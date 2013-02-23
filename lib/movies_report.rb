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
        links = Search.new(title).links

        # TODO: parse ratings from..
        doc = Net::HTTP.get_response(URI("http://#{links.first.last}"))
        # ap [ title, links.first, doc ]
        # ap "------------"

        { title: title, links: links}
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

  class Search
    include FetchDocument

    SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

    def initialize(title)
      @title = title
    end

    def links
      uri = URI(SEARCH_MOVIE_URL % CGI::escape(@title))
      doc = fetch_document(uri)

      each_search_result(doc) do |el|
        [el.content.strip, uri.host + el.attr('href')]
      end
    end

    def each_search_result(document, &block)
      document.css('.searchResult a.searchResultTitle').map do |el|
        yield(el)
      end
    end
  end

  class DSL
    def self.parse_html(url)
      Report.new(url).run!
    end
  end
end
