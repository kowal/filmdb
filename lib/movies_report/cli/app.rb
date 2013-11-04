# coding: utf-8

module MoviesReport

  module Cli

    # Command Line i-face for MoviesReport
    #
    class App

      CLI_JOB_REFRESH_INTERVAL = 0.5
      CLI_LOG_FORMATTER = proc { |_, _, _, msg| "[MoviesReport] #{msg}\n" }

      def self.start(argv)
        options = parse_options(argv)
        setup_logging
        self.run(options.marshal_dump)
      end

      def self.setup_logging
        Sidekiq::Logging.logger = nil
        MoviesReport.logger.level = Logger::INFO
        MoviesReport.logger.formatter = CLI_LOG_FORMATTER
      end

      def self.parse_options(argv)
        MoviesReport::CommandLineOptions.parse(argv)
      end

      def self.run report_options = {}
        report_options = default_options.merge(report_options)

        if report_options[:job_id]
          result = report_job_status(report_options[:job_id])
          print_job_results(result)
        else
          if report_options[:background]
            if report_options[:keep]
              job_progress = Progressbar.new(CLI_JOB_REFRESH_INTERVAL)
              movies_report = create_report(report_options)

              job_id = report_add_job movies_report.workers_ids
              job_progress.for_each_step do
                report_job_status(job_id.to_i, workers_ids: movies_report.workers_ids)
              end
              print_job_results(job_progress.result)
            else
              movies_report = create_report(report_options)
              job_id = report_add_job movies_report.workers_ids
              MoviesReport.logger.info "Scheduled job => #{job_id}"
            end
          else
            movies_report = create_report(report_options)
            MoviesReport.logger.info "Building finished."
            report_in_console movies_report
          end
        end
      end

      def self.print_job_results(result)
        finished = result[:status][:finished]
        total = result[:status][:started] + finished
        MoviesReport.logger.info "Results: (#{finished}/#{total})"
        result.delete :status
        ap result
        exit
      end

      def self.create_report report_options
        MoviesReport.logger.info "Building report. Please wait.."
        MoviesReport::Report.new(report_options).tap do |movies_report|
          movies_report.build!
        end
      end

      def self.report_in_console(movies_report)
        TableReporter.new(movies_report.data).display
      end

      def self.report_add_job(workers_ids)
        BackgroundJob.new(workers_ids).save
      end

      def self.report_job_status(job_id, opts={})
        BackgroundJob.find(job_id, opts)
      end

      def self.default_options
        { engine: Source::Chomikuj }
      end

    end
  end
end