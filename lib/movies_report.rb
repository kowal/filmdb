require "movies_report/version"
require 'nokogiri'
require 'open-uri'

module MoviesReport

  TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG lektor Lektor .napisy
   --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
   .pl PL ivo chomikuj Chomikuj.avi .avi dubbing.pl.avi }

  class DSL

	  # prototype
	  # 1st use case:
	  # for given url, return list of movies (with rankings from other services)
	  def self.parse_html(url)
		doc = Nokogiri::HTML(open(url))

		doc.css('#FilesListContainer .fileItemContainer .filename').map do |el|
		  n = el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
		  puts n
		  # TODO: remove 'lektor' etc..
		  n
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
