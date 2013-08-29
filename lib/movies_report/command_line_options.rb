# coding: utf-8

require 'optparse'
require 'ostruct'

module MoviesReport

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: movies-report [options] source_url"

        opts.on('-u', '--url URL', 'URL with movies to check') do |url|
          options.url = url
        end

      end

      opt_parser.parse!(args)
      options
    end

  end

end