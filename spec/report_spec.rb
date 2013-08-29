# coding: utf-8

require 'spec_helper'

describe MoviesReport::Report do

  # dumb search engine impl.
  class FakeSearchEngine
    def initialize(url) end
  end

  let(:movies_url) { 'http://does.not.matter.com' }
  let(:search_engine_klass) { FakeSearchEngine }

  context 'on build' do

    subject(:report) {
      MoviesReport::Report.new url: movies_url, engine: search_engine_klass
    }

    it 'returns title and rankings for each movie' do
      report.expects(:filmweb_rating).with('MovieA').returns('5.0')
      report.expects(:filmweb_rating).with('MovieB').returns('6.0')
      report.expects(:imdb_rating).with('MovieA').returns('7.0')
      report.expects(:imdb_rating).with('MovieB').returns('8.0')

      FakeSearchEngine.any_instance.stubs(:all_movies).returns([
        { title: 'MovieA' },
        { title: 'MovieB' },
        { title: 'MovieB' } # doubled titles should be ignored
      ])

      expect(report.build!).to eq([
        { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
        { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
      ]), 'Report results should include proper ratings'
    end

    it 'returns empty results when no movies are found' do
      FakeSearchEngine.any_instance.stubs(:all_movies).returns([])

      expect(report.build!).to be_empty
    end
  end
end
