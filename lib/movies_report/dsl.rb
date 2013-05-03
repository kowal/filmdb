module MoviesReport
  class DSL
    def self.report_for(url=nil)
      raise 'No url given!' unless url

      Report.new(url, Movie::Chomikuj).build!
    end
	end
end