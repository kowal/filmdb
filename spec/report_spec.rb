# coding: utf-8

require 'spec_helper'

describe MoviesReport::Report do

  # dumb search engine impl.
  class FakeSearchEngine
    attr_accessor :movies
    def initialize(url); end
    def each_movie; movies.each { |m| yield(m) } ; end
  end

  let(:movies_url) { "http://does.not.matter.com" }
  let(:search_engine_klass) { FakeSearchEngine }

  context 'on build' do

    it 'returns title and rankings for each movie' do
      report = MoviesReport::Report.new(movies_url, search_engine_klass)

      report.expects(:filmweb_rating).with('MovieA').returns('5.0')
      report.expects(:filmweb_rating).with('MovieB').returns('6.0')
      report.expects(:imdb_rating).with('MovieA').returns('7.0')
      report.expects(:imdb_rating).with('MovieB').returns('8.0')

      FakeSearchEngine.any_instance.stubs(:movies).returns([
        { title: 'MovieA' },
        { title: 'MovieB' }
      ])

      expect(report.build!).to eq([
        { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
        { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
      ]), 'Report should include proper ratings'
    end
  end
end
