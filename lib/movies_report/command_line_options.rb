# coding: utf-8

require 'optparse'
require 'ostruct'

module MoviesReport

  class CommandLineOptions

    def self.parse(args)
      options = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: movies-report [options] source_url"

        opts.on('-s', '--source SOURCE_URL',
                'Source of movies to check') do |source_url|
          options.source_url = source_url
        end
      end

      opt_parser.parse!(args)
      options
    end

  end

end