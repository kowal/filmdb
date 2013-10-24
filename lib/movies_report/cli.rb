# coding: utf-8

module MoviesReport

  # Command Line i-face for MoviesReport
  #
  class CLI

    def self.start(argv)
      options = parse_options(argv)
      self.run(options.marshal_dump)
    end

    def self.parse_options(argv)
      MoviesReport::CommandLineOptions.parse(argv)
    end

    def self.run(report_options={})
      MoviesReport.debug = true

      # this can take some time..
      ap "Movies Report started."
      movies_report = DSL.report_for(report_options)

      if report_options[:background]
        BackgroundReporter.new(movies_report).run
      else
        # display report
        ConsoleReporter.new(movies_report.data).display
      end
    end
  end
end