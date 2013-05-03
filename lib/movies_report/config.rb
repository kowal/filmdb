module MoviesReport

  class << self
    attr_accessor :debug

    def configure
      yield self
    end
  end

end