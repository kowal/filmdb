# coding: utf-8

require 'redis'
require "json"

module MoviesReport

  # Stores Sidekiq workers IDs and reads their statuses
  # 
  # Store
  #   job = BackgroundJob.new [ '732939232', '9688471622', ... ]
  #   job.save # => '15'
  #
  # Read
  #   statuses = BackgroundJob.find(15) # or '15'
  #   statuses.first # => { status: 'complete', update_time: 1360006573, foo: 'bar'}
  #
  class BackgroundJob

    STORAGE = Redis.new
    class << self

      def find(job_id, opts={})
        workers_ids = opts.fetch(:workers_ids) { JSON.parse(STORAGE.get(job_id.to_s)) }

        results = {}
        stats = { started: 0, finished: 0 }
        workers_ids.each do |worker_id|
          data = Sidekiq::Status::get_all worker_id

          return {} unless data['state']

          stats[data['state'].to_sym] += 1

          results[data['title']] ||= []
          if data['rating'] && data['rating'] != '' && data['rating'] != '0.0'
            results[data['title']] << Float(data['rating'])
          end
        end
        hash_results = { status: stats }
        results.map do |title, ratings|
          hash_results[title] = ratings.compact.inject{ |sum, el| sum + el }.to_f / ratings.size
        end
        hash_results
      end

      def valid_float?(str)
        !!Float(str) rescue false
      end
    end

    def initialize(workers_ids)
      @workers_ids= workers_ids
    end

    def save
      job_id = next_job_id
      STORAGE.set job_id, @workers_ids.to_json
      job_id
    end

    private

    def next_job_id
      STORAGE.incr "movies-report-last-job"
    end
    
  end
end