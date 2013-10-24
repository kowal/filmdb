# coding: utf-8

module MoviesReport

  class DSL

    def self.report_for(report_options={})
      report = Report.new(report_options.merge(default_options))
      report.build!
    end

    def self.default_options
      { engine: Source::Chomikuj }
    end

  end

end