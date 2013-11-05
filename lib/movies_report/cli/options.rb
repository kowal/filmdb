# coding: utf-8

require 'optparse'
require 'ostruct'

module MoviesReport

  module Cli

    class Options

      def self.parse(args)
        options = OpenStruct.new

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: movies-report [OPTIONS]"

          opts.on('-u', '--url URL', 'URL with movies to check') do |url|
            options.url = url
          end

          opts.on('-k', '--keep KEEP_CONNECTION', 'Keep connection until all job are finished') do
            options.keep = true
          end

          opts.on('-j', '--job JOB_ID', 'Read Status of job') do |job_id|
            options.job_id = job_id
          end

        end

        opt_parser.parse!(args)
        options
      end

    end

  end

end