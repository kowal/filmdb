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
        MoviesReport::Cli::Options.parse(argv)
      end

      def self.run report_options = {}
        job_id = report_options[:job_id]
        keep   = report_options[:keep]
        url    = report_options[:url]

        if job_id
          result = job_status(job_id)
          print_job_results(result)
        else
          report = create_report url: url
          if keep
            result = create_job_and_pool(report)
            print_job_results(result)
          else
            result = create_job(report.workers_ids)
            print_job_results(result)
          end
        end
      end

      def self.job_status(job_id)
        workers_ids = BackgroundJob.find job_id
        BackgroundStrategy.new.current_result(workers_ids)
      end

      def self.create_report(options)
        options.merge!(CLI_DEFAULT_OPTIONS)
        MoviesReport::Report.new(options).tap do |report|
          report.build!(:background)
        end
      end

      def self.create_job(workers_ids)
        BackgroundJob.new(workers_ids).save.to_s
      end

      def self.create_job_and_pool(report)
        job_progress = Progressbar.new(CLI_JOB_REFRESH_INTERVAL)
        job_progress.for_each_step do
          BackgroundStrategy.new.current_result(report.workers_ids)
        end
        job_progress.result
      end

      def self.print_job_results(result)
        if result.is_a?(String)
          MoviesReport.logger.info "Scheduled job => #{result}"
          exit
        end
        finished = result[:status][:finished]
        total = result[:status][:started] + finished
        MoviesReport.logger.info "Results: (#{finished}/#{total})"
        result.delete :status
        ap result
      end

      def self.report_in_console(movies_report)
        TableReporter.new(movies_report.data).display
      end

    end
  end
end