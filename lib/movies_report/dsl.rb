# coding: utf-8

module MoviesReport

  class DSL

    def self.report_for(report_options={})
      opts = report_options.merge engine: Source::Chomikuj

      Report.new(opts).build!
    end

  end

end