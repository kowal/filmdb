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
        ap "Now you have to pool workers about the results..."
        ap movies_report
        ap 'By!'
      else
        # display report
        ConsoleReporter.new(movies_report).display
      end
    end
  end
end