# coding: utf-8

module MoviesReport

  module Cli

    # Command Line i-face for MoviesReport
    #
    class App

      CLI_JOB_REFRESH_INTERVAL = 0.5
      CLI_LOG_FORMATTER        = proc { |_, _, _, msg| "[FilmDB] #{msg}\n" }
      CLI_DEFAULT_OPTIONS      = { engine: Source::Chomikuj }

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
        Cli::Options.parse(argv)
      end

      def self.run report_options = {}
        job_id = report_options[:job_id]
        keep   = report_options[:keep]
        url    = report_options[:url]

        result = if job_id
          job_status(read_job(job_id))
        else
          report = create_report url: url
          if keep
            refresh_job_status(report)
          else
            save_job(report)
          end
        end
        print_job_results(result)
      end

      def self.job_status(workers_ids)
        Strategy::Background.new.current_result(workers_ids)
      end

      def self.create_report(options)
        options.merge!(CLI_DEFAULT_OPTIONS)
        Report.new(options).tap do |report|
          report.build!(:background)
        end
      end

      def self.refresh_job_status(report)
        job_progress = Progressbar.new(CLI_JOB_REFRESH_INTERVAL)
        job_progress.for_each_step { job_status(report.workers_ids) }
        job_progress.result
      end

      def self.save_job(report)
        BackgroundJob.new(report.workers_ids).save.to_s
      end

      def self.read_job(job_id)
        BackgroundJob.find(job_id)
      end

      def self.print_job_results(result)
        if result.is_a?(String)
          MoviesReport.logger.info "Scheduled job => #{result}"
          exit
        end
        finished = result[:status][:finished]
        total = result[:status][:started] + finished
        MoviesReport.logger.info "Results:"
        result.delete :status
        ap result
      end

      def self.report_in_console(movies_report)
        TableReporter.new(movies_report.data).display
      end

    end
  end
end