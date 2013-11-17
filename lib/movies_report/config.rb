# coding: utf-8

module MoviesReport

  class << self

    attr_accessor :logger

    # Simple config helper
    #
    # MoviesReport.configure do |config|
    #   config.foo = 'bar'
    # end
    #
    def configure
      yield self
    end

    def register_source(url, source_class)
    end

    def register_service(service_name, service_class)
      services[service_name] = service_class
    end

    def register_strategy(strategy_name, strategy_class)
      strategies[strategy_name] = strategy_class
    end

    def strategies
      @strategies ||= {}
    end

    def services
      @services ||= {}
    end
  end

end