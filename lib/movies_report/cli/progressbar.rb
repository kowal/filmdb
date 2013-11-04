# coding: utf-8

require 'timeout'

module MoviesReport

  module Cli

    class Progressbar

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
  end
end
