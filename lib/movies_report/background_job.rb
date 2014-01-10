# coding: utf-8

module MoviesReport

  # Stores/reads Sidekiq workers IDs
  # 
  # Store
  #   job = BackgroundJob.new [ '732939232', '9688471622', ... ]
  #   job.save # => '15'
  #
  # Read
  #   statuses = BackgroundJob.find(15) # or '15'
  #   statuses # => [ '732939232', '9688471622', ... ]
  #
  class BackgroundJob

    STORAGE = Redis.new
    class << self

      def find(job_id)
        JSON.parse(STORAGE.get(job_id.to_s))
      end

    end

    def initialize(workers_ids)
      @workers_ids = workers_ids
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