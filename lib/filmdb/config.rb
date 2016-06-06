# coding: utf-8

require 'uri'

module FilmDb
  class << self
    attr_accessor :logger

    # Simple config helper
    #
    # FilmDb.configure do |config|
    #   config.foo = 'bar'
    # end
    #
    def configure
      yield self
    end

    def register_source(source_url, source_class)
      sources[URI(source_url).hostname] = source_class
    end

    def register_service(service_name, service_class)
      services[service_name] = service_class
    end

    def register_strategy(strategy_name, strategy_class)
      strategies[strategy_name] = strategy_class
    end

    def sources
      @sources ||= {}
    end

    def strategies
      @strategies ||= {}
    end

    def services
      @services ||= {}
    end
  end
end
