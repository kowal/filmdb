require "movies_report/version"
require 'nokogiri'
require 'open-uri'

module MoviesReport

  class DSL

	  # prototype
	  # 1st use case:
	  # for given url, return list of movies (with rankings from other services)
	  def self.parse_html(url)
		doc = Nokogiri::HTML(open(url))

		doc.css('#FilesListContainer .fileItemContainer .filename').map do |el|
		  puts el.content.strip
		  el.content.strip
		end
	  end

  end
end
