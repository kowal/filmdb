# coding: utf-8

module MoviesReport
  class DSL
    def self.report_for(url = nil, options = {})
      raise 'No url given!' unless url

      report = Report.new(url, Source::Chomikuj)

      report.build!
    end
  end
end