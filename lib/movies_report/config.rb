# coding: utf-8

module MoviesReport

  class << self

    attr_accessor :logger

    def configure
      yield self
    end
  end

end