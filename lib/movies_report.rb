require "movies_report/version"
require 'nokogiri'
require "net/http"
require "uri"
require 'vcr'

module MoviesReport

  TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG
    lektor Lektor lekyor .napisy
    -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
    .pl PL ivo
    chomikuj Chomikuj.avi .avi dubbing.pl.avi
  }

  class DSL

    def self.parse_html(url)
      doc = Nokogiri::HTML(Net::HTTP.get_response(URI(url)).body)

      doc.css('#FilesListContainer .fileItemContainer .filename').map do |el|
        el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
      end
    end
    # check filmweb

    # http://www.filmweb.pl/search?q=MOVIE_QUERY
    # on result page
    # movies_links = doc.css('.searchResult a.searchResultTitle').map do |el|
    #   el.href
    # end
  end
end
