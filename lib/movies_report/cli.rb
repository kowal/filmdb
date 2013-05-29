# coding: utf-8

module MoviesReport
  class CLI
    # Usage
    # bin/movies-report <URL>
    def self.run(url)
      MoviesReport.debug = true

      DSL.report_for(url, { workers: 4 })
    end
  end
end