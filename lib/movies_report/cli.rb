# coding: utf-8

require 'timeout'

module MoviesReport

  # Command Line i-face for MoviesReport
  #
  class CLI

    JOB_PROGRESS_TIMEOUT = 0.5

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
        result = report_job_status(report_options[:job_id])
        print_job_results(result)
      else
        movies_report = create_report(report_options)

        if report_options[:background]
          job_id = report_add_job movies_report.workers_ids

          if report_options[:keep]
            job_progress = JobProgress.new(JOB_PROGRESS_TIMEOUT)
            job_progress.start_polling! do
              report_job_status(job_id.to_i, workers_ids: movies_report.workers_ids)
            end
            print_job_results(job_progress.result)
          end
        else
          report_in_console movies_report
        end
      end
    end

    class JobProgress

      attr_reader :result

      def initialize(timeout_in_seconds)
        @timeout_in_seconds = timeout_in_seconds
        @progressbar = nil
        @result = nil
        @pending_jobs = true
      end

      def start_polling!(&block)
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
        ProgressBar.create({
          :title => "Fetching Movie Stats",
          :starting_at => 0,
          :total => total,
          :length => 100,
          :format => '%t [%c/%C] |%B| %p%'
        })
      end
    end

    def self.print_job_results(result)
      result.delete :status
      ap result
      exit
    end


    def self.create_report report_options
      MoviesReport::Report.new(report_options).tap do |movies_report|
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