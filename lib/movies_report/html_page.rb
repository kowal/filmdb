# coding: utf-8

require 'nokogiri'
require 'awesome_print'
require 'net/http'
require 'uri'

module MoviesReport

  # HtmlPage
  # - fetches html page
  # - uses Nokogiri, Net:HTTP
  #
  class HtmlPage
    attr_reader :uri, :document

    def initialize(uri)
      @uri = uri.respond_to?(:host) ? uri : URI(URI.encode(uri))
      @document = Nokogiri::HTML(Net::HTTP.get_response(@uri).body)
    rescue => e
      $stderr.puts "Cant fetch page from : '#{@uri}' #{e.message}"
      $stderr.puts e.backtrace
      nil
    end
  end

end