# coding: utf-8

module MoviesReport

  class BackgroundReporter
    def initialize(movies_report, options={})
      @movies_report = movies_report
    end

    def run
      ap "Now you have to pool workers about the results..."
      ap @movies_report.data.size
      ap 'By!'
    end
  end
end