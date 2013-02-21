require "movies_report/version"
require 'nokogiri'
require "net/http"
require "uri"

module MoviesReport

  TO_REMOVE = %w{ .BRRiP MX DVDRiP DVDRip XViD PSiG
    lektor Lektor lekyor .napisy
    -orgonalny --orgonalny --orgoinalny .oryginalny oryginalny --oryginalny --orginalny orginalny
    .pl PL ivo
    chomikuj Chomikuj.avi .avi dubbing.pl.avi
  }

  MATCHERS = {
    'chomikuj.pl'     => '#FilesListContainer .fileItemContainer .filename',
    'www.filmweb.pl'  => '.searchResult a.searchResultTitle'
  }

  CHECK_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

  class DSL

    def self.parse_html(url)
      uri = URI(url)
      doc = Nokogiri::HTML(Net::HTTP.get_response(uri).body)

      doc.css(MATCHERS[uri.host]).map do |el|
        title = parse_title(el)
        links = search_movies(title)
        puts "GOT #{title}, #{links}"

        { title: title, links: links}
      end
    end

    def self.parse_title(el)
      el.content.strip.gsub(/#{TO_REMOVE.join('|')}/, '').strip.gsub(/[-\s\.]+$/, '')
    end

    def self.search_movies(title)
      uri = URI(CHECK_MOVIE_URL % CGI::escape(title))
      doc = Nokogiri::HTML(Net::HTTP.get_response(uri).body)

      doc.css(MATCHERS[uri.host]).map do |el|
        [el.content.strip, el.attr('href')]
      end
    end
  end
end
