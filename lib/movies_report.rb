require "movies_report/version"
require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"

module MoviesReport

  TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG
    lektor Lektor lekyor .napisy
    -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
    .pl PL ivo
    chomikuj Chomikuj.avi .avi dubbing.pl.avi
  }

  HOST_TO_SELECTOR = {
    chomikuj: '#FilesListContainer .fileItemContainer .filename',
    filmweb:  '.searchResult a.searchResultTitle'
  }

  CHECK_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

  class DSL

    def self.parse_html(url)
      uri = URI(url)
      doc = fetch_document(uri)

      each_movie_title(doc) do |el|
        title = parse_title(el)
        links = search_movies(title)
        # doc = Net::HTTP.get_response(URI("http://#{links.first.last}"))
        # ap [ title, links.first, doc ]
        # ap "------------"

        { title: title, links: links}
      end
    end

    def self.parse_title(el)
      el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
    end

    def self.search_movies(title)
      uri = URI(CHECK_MOVIE_URL % CGI::escape(title))
      doc = fetch_document(uri)

      each_search_result(doc) do |el|
        [el.content.strip, uri.host + el.attr('href')]
      end
    end

    def self.each_movie_title(document, &block)
      document.css(HOST_TO_SELECTOR[:chomikuj]).map do |el|
        yield(el)
      end
    end

    def self.each_search_result(document, &block)
      document.css(HOST_TO_SELECTOR[:filmweb]).map do |el|
        yield(el)
      end
    end

    private

    def self.fetch_document(uri)
      Nokogiri::HTML(Net::HTTP.get_response(uri).body)
    end

  end
end
