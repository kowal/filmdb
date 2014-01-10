# coding: utf-8

module MoviesReport

  module Strategy

    # Strategy for retrieving movies stats in background (none-blocking)
    #
    # Uses MoviesReport::WebSearchWorker internally.
    #
    class Background < Base

      # @retutn [String] worker_id ID which fetches info for given title
      def each_film(title, service, service_key)
        MoviesReport::WebSearchWorker.perform_async(title, service_key)
      end

      # @param [Array] workers_ids
      # @return [Hash] hash with current results
      def current_result(workers_ids)
        results = {}
        stats = { started: 0, finished: 0 }
        workers_ids.each do |worker_id|
          data = MoviesReport::WebSearchWorker.get_worker_data(worker_id)

          return {} unless data['state']

          stats[data['state'].to_sym] += 1

          results[data['title']] ||= []
          if data['rating'] && data['rating'] != '' && data['rating'] != '0.0'
            results[data['title']] << Float(data['rating'])
          end
        end
        hash_results = { status: stats }
        results.map do |title, ratings|
          hash_results[title] = (ratings.compact.reduce { |sum, el| sum + el }.to_f / ratings.size).round(1)
        end
        hash_results
      end

    end

  end

end
