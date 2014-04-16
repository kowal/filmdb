# coding: utf-8

module MoviesReport

  module Strategy

    # Strategy for retrieving movies stats in background (none-blocking)
    #
    # Uses MoviesReport::WebSearchWorker internally.
    #
    class Background < Base

      # @return [String] worker_id ID which fetches info for given title
      #
      def each_film(title, service, service_key)
        MoviesReport::WebSearchWorker.perform_async(title, service_key)
      end

      # @param [Array] workers_ids
      # @return [Hash] hash with current results
      #
      def current_result(workers_ids)
        calculate_current_results(workers_ids)
      end

      # @private
      def calculate_current_results(workers_ids)
        results = StatsCollection.new

        workers_ids.each do |worker_id|
          stats = ResultsStats.new(read_worker_data(worker_id))
          return {} unless stats.valid? # TODO: this should not be required

          results.increment_state_counter(stats['state'])
          results.add_rating(stats['title'], stats.get_rating)
        end

        results.calculate_ratings
      end

      def read_worker_data(worker_id)
        MoviesReport::WebSearchWorker.get_worker_data(worker_id)
      end

      # @private
      class StatsCollection

        def initialize
          @results = {}
          @hash_results = { status: { started: 0, finished: 0 } }
        end

        def increment_state_counter(state)
          @hash_results[:status][state.to_sym] += 1
        end

        def add_rating(title, rating)
          return unless rating

          (@results[title] ||= []) << rating
        end

        def calculate_ratings
          @results.map do |title, ratings|
            @hash_results[title] = (ratings.compact.reduce { |sum, el| sum + el }.to_f / ratings.size).round(1)
          end
          @hash_results
        end

      end

      # @private
      class ResultsStats

        def initialize(data)
          @data = data
        end

        def [](attr_name)
          @data[attr_name]
        end

        def valid?
          @data['state'] != nil
        end

        def get_rating
          Float(@data['rating']) if valid_rating?(@data['rating'])
        end

        def valid_rating?(rating)
          rating && rating != '' && rating != '0.0'
        end

      end

    end

  end

end
