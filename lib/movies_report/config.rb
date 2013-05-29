# coding: utf-8

module MoviesReport

  class << self
    attr_accessor :debug, :workers

    def configure
      yield self
    end
  end

end