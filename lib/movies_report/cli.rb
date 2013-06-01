# coding: utf-8

module MoviesReport

  # TODO: add OptionParse / GLI for this class as an entry point
  #
  class CLI

    # Usage
    # bin/movies-report <URL>
    def self.run(url)
      MoviesReport.debug = true

      # this can take some time..
      ap "Generating movies stats. Please wait..."
      movies_report = DSL.report_for(url)

      # display report
      ConsoleReporter.new(movies_report).display
    end
  end
end