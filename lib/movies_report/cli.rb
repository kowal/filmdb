# coding: utf-8

require 'timeout'

module MoviesReport

  # Command Line i-face for MoviesReport
  #
  class CLI

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
            job_progress = JobProgress.new(CLI_JOB_REFRESH_INTERVAL)
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

    class JobProgress

      attr_reader :result, :progressbar

      def initialize(timeout_in_seconds)
        @timeout_in_seconds = timeout_in_seconds
        @progressbar = nil
        @result = nil
        @pending_jobs = true
      end

      def for_each_step(&block)
        while @pending_jobs
          begin
            Timeout::timeout(@timeout_in_seconds) do
              @result = block.call
              update_progressbar(@result[:status])
            end
          rescue Timeout::Error
            next
          end
        end
      end

      def update_progressbar(status)
        return unless status

        started = status[:started]
        finished = status[:finished]

        @pending_jobs = started.to_i > 0
        if @pending_jobs
          @progressbar ||= create_progressbar(started + finished)
          @progressbar.progress = finished
        end
      end

      def create_progressbar(total)
        @progressbar = ProgressBar.create({
          :title => "[MoviesReport] Fetching stats",
          :starting_at => 0,
          :total => total,
          :length => 100,
          :format => '%t [%c/%C] |%B| %p%'
        })
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
      MoviesReport::Report.new(report_options).tap do |movies_report|
        MoviesReport.logger.info "Building report. Please wait.."
        movies_report.build!
      end
    end

    def self.report_in_console(movies_report)
      ConsoleReporter.new(movies_report.data).display
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