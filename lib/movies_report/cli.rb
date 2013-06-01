# coding: utf-8

module MoviesReport

  class CLI

    def self.start(argv)
      options = parse_options(argv)
      self.run(options)
    end

    def self.parse_options(argv)
      MoviesReport::CommandLineOptions.parse(argv)
    end

    # Usage
    # bin/movies-report <URL>
    def self.run(options)
      MoviesReport.debug = true

      # this can take some time..
      ap "Generating movies stats. Please wait..."
      movies_report = DSL.report_for(options.source_url)

      # display report
      ConsoleReporter.new(movies_report).display
    end
  end
end