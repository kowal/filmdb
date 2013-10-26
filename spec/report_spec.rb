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
      # stub movies
      stub_movies_search([
        { title: 'MovieA' },
        { title: 'MovieB' },
        { title: 'MovieB' } # doubled titles should be ignored
      ])
      # stub ratings
      report.expects(:filmweb_rating).with('MovieA').returns('5.0')
      report.expects(:filmweb_rating).with('MovieB').returns('6.0')
      report.expects(:imdb_rating).with('MovieA').returns('7.0')
      report.expects(:imdb_rating).with('MovieB').returns('8.0')
      # expected
      expected_data = [
        { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
        { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
      ]

      report.build!
      expect(report.data).to eq(expected_data),
        'Report results should include proper ratings'
    end

    it 'returns empty results by default' do
      expect(report.data).to be_empty
    end

    it 'returns empty results when no movies are found' do
      stub_movies_search []

      report.build!
      expect(report.data).to be_empty
    end

    def stub_movies_search(data)
      FakeSearchEngine.any_instance.stubs(:all_movies).returns(data)
    end
  end

  context 'run on real page' do

    it 'finds all movies included in the page', req: '958909' do

      VCR.use_cassette('chomikuj', record: :new_episodes) do
        expected_movies = expected_results_for_site('chomikuj')

        report = MoviesReport::Report.new url: 'http://chomikuj.pl/mocked-page', engine: MoviesReport::Source::Chomikuj
        report.build!
        actual_movies = report.data.map { |m| m[:title] }

        expect(actual_movies).to include(*expected_movies)
      end
    end

  end

end
