require "movies_report/version"
require "movies_report/sanitizer/chomikuj"
require 'nokogiri'
require "net/http"
require "uri"
require "awesome_print"
require "imdb"

module MoviesReport

  module FetchDocument
    def fetch_document(uri)
      Nokogiri::HTML(Net::HTTP.get_response(uri).body)
    rescue => e
      ap "Cant fetch document from : '#{uri}' #{e.message}"
      ap e.backtrace
      nil
    end
  end

  module Movie

    class Chomikuj

      class << self

        def sanitize_title(original_title)
          sanitized_title = MoviesReport::Sanitizer::Chomikuj.clean(original_title)
          # ap "'#{original_title}' => '#{sanitized_title}'"
          sanitized_title
        end

        def each_movie(document, &block)
          return unless document

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

          page_type = document.css('.noFile').empty? ? :file_list : :folder_list
          page = pages[page_type]

          document.css(page[:selector]).map do |el|
            # yield calculated field values: {:title=>"XXX", :size=>"xxx"}
            yield(Hash[page[:fields].map { |field, value_proc | [field, value_proc.call(el) ]}])
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
        title = movie[:title]
        ratings = build_rankings(title)

        #ap "=> #{title} (#{ratings}) #{movie[:size]}"

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
      rescue => e
        ap "Can fetch IMDB results for #{@title}"
        ap e.message
        []
      end

    end

    class Filmweb < BaseSearch

      SEARCH_MOVIE_URL = "http://www.filmweb.pl/search?q=%s"

      # fetch ratings from 1st result:
      def rating
        return '' unless @results.first
        # "7,1/10" => "7.1"
        return @results.first[:rating].gsub(/\/.*/, '').gsub(',','.').to_f rescue ''
      end

      # @return [ [title, url], ... ]
      def read_results
        uri = URI(SEARCH_MOVIE_URL % CGI::escape(@title))
        doc = fetch_document(uri)

        each_search_result(doc) do |el|
          { rating: el.content.strip }
        end
      end

      def each_search_result(document, &block)
        return unless document
        document.css(".resultsList .rateInfo strong").map do |el|
          yield(el)
        end
      end
    end
  end

  class DSL
    def self.parse_html(url=nil)
      raise 'No url given!' unless url

      Report.new(url).run!
    end
  end
end
