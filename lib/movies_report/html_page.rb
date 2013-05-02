module MoviesReport

  # HtmlPage
  # - fetches html page
  # - uses Nokogiri, Net:HTTP
  #
  class HtmlPage
    attr_reader :uri, :document

    def initialize(uri)
      @uri = uri
      @document = Nokogiri::HTML(Net::HTTP.get_response(@uri).body)
    rescue => e
      ap "Cant fetch page from : '#{@uri}' #{e.message}"
      ap e.backtrace
      nil
    end
  end

end