# coding: utf-8

module MoviesReport

  # Command Line i-face for MoviesReport
  #
  class CLI

    def self.start(argv)
      MoviesReport.debug = true
      options = parse_options(argv)
      self.run(options.marshal_dump)
    end

    def self.parse_options(argv)
      MoviesReport::CommandLineOptions.parse(argv)
    end

    def self.run report_options = {}
      report_options = default_options.merge(report_options)

      if report_options[:job_id]
        result = report_job_status(report_options)
        ap result
        exit
      else
        movies_report = create_report(report_options)

        if report_options[:background]
          job_id = report_add_job movies_report
          puts "To check status run:\n bin/movies_report --job #{job_id}"
        else
          report_in_console movies_report
        end
      end
    end

    def self.create_report report_options
      MoviesReport::Report.new(report_options).tap do |movies_report|
        movies_report.build!
      end
    end

    def self.report_in_console(movies_report)
      ConsoleReporter.new(movies_report.data).display
    end

    def self.report_add_job(movies_report)
      BackgroundJob.new(movies_report.all_ratings).save
    end

    def self.report_job_status(report_options)
      BackgroundJob.find(report_options[:job_id])
    end

    def self.default_options
      { engine: Source::Chomikuj }
    end

  end
end