require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"
require "imdb"

module MoviesReport

  class << self
    attr_accessor :debug

    def configure
      yield self
    end
  end

  require "movies_report/version"
  require "movies_report/html_page"
  require "movies_report/report"

  require "movies_report/sanitizer/chomikuj"

  require "movies_report/search/base_search"
  require "movies_report/search/filmweb"
  require "movies_report/search/imdb"

  module Movie

    # Movie::Chomikuj:
    # - takes service specific uri
    # - finds all movies information on given service page
    # - provides iterator, which yields all found movies with their page-specific properties
    #   (i.e. title + size + comment)

    # TODO: make it Seach subclass
    class Chomikuj

      def initialize(uri)
        @document = HtmlPage.new(uri).document
      end

      def each_movie(&block)
        return unless @document

        pages = { 
          folder_list: {
            selector: '#foldersList a',
            fields: {
              title: ->(el) { sanitize_title(el.content.strip) }
            }
          },
          file_list: {
            selector: '#FilesListContainer .fileItemContainer',
            fields: {
              title: ->(el) { sanitize_title(el.css('.filename').first.content.strip) },
              size:  ->(el) { el.css('.fileinfo li:nth-last-child(2)').first.content }
            }
          }
        }

        page_type = @document.css('.noFile').empty? ? :file_list : :folder_list
        page = pages[page_type]

        @document.css(page[:selector]).map do |el|
          # build properties structure: [ [ 'title', 'XXX' ], [ 'size', '200' ] ]
          movie_properties = page[:fields].map { |field, value_proc| [field, value_proc.call(el) ]}

          # yield properties as hashes: {:title => 'XXX', :size => '200'}
          yield(Hash[movie_properties])
        end
      end

      private

      def sanitize_title(original_title)
        MoviesReport::Sanitizer::Chomikuj.clean(original_title)
      end

    end
  end

  class DSL
    def self.report_for(url=nil)
      raise 'No url given!' unless url

      Report.new(url, Movie::Chomikuj).build!
    end
  end

  class CLI

    # Usage
    # bin/movies-report <URL>
    def self.run(url)
      MoviesReport.debug = true
      DSL.report_for(url)
    end
  end
end

MoviesReport.configure do |config|
  config.debug = false
end
