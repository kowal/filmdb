# coding: utf-8

require 'timeout'

module FilmDb

  module Cli

    # Simple CLI progress-bar build around 'Sparks' visualizaiton.
    #
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
              update_progressbar(@result)
            end
          rescue Timeout::Error
            next
          end
        end
      end

      # Redraw progressbar with given result.
      #
      # @param [Hash] data result to display
      # @example Update progressbar with new data
      #   update_progressbar( status: { started: 40, finished: 60 } )
      #
      def update_progressbar(result)
        return unless result[:status]

        started = result[:status][:started]
        finished = result[:status][:finished]

        @pending_jobs = started.to_i > 0
        if @pending_jobs
          @progressbar ||= create_progressbar(started + finished)
          update_progress "%t [%c/%C] #{sparks(sparks_values(result.values))} %p%", finished
        else
          update_progress ''
        end
      end

      # @private
      def update_progress(message, finished_jobs = nil)
        @progressbar.format message
        if finished_jobs
          @progressbar.progress = finished_jobs
        else
          @progressbar.log('[FilmDB] Finished!')
        end
      end

      # @private
      def create_progressbar(total)
        @progressbar = ProgressBar.create({
          title:       '[FilmDB] Fetching stats',
          starting_at: 0,
          length:      70,
          total:       total
        })
      end

      # @private
      def sparks_values(values)
        valid_data = values[1..-1]
        valid_data.map { |v| v.nan? ? 0 : (v.to_i - 4) } if valid_data
      end

      # Sparks visualizaiton
      # Taken from https://gist.github.com/jcromartie/1367091
      #
      def sparks(values)
        @ticks = %w[▁ ▂ ▃ ▄ ▅ ▆ ▇]
        values = values.map { |x| x.to_f }
        min, range, scale = values.min, values.max - values.min, @ticks.length - 1
        if !(range == 0)
          values.map { |x| @ticks[(((x - min) / range) * scale).round] }.join
        else
          values.map { |x| @ticks[1] }.join
        end
      end

    end
  end
end
