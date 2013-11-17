# coding: utf-8

require 'spec_helper'

describe MoviesReport::Report do

  # dumb search engine impl.
  class FakeSearchEngine
    def initialize(url) end
  end

  let(:movies_url) { 'http://does.not.matter.com' }
  let(:search_engine_klass) { FakeSearchEngine }

  context 'on create' do

    it 'requires url' do
      # MoviesReport::Report.new
    end

    it 'recognizes search engine' do
      # MoviesReport::Report.register_search 'my.search.engine.pl', FakeSearchEngine
    end
  end

  context 'on build with default strategy' do

    subject(:report) {
      MoviesReport::Report.new url: movies_url, engine: search_engine_klass
    }

    it 'returns title and rankings for each movie' do
      movies = expect_movies_in_source([
        { title: 'MovieA' },
        { title: 'MovieB' }
      ])
      expected_data = [
        { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
        { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
      ]
      expect_run_strategy(:default).with(movies).returns(expected_data)

      report.build!

      expect(report.data).to eq(expected_data),
        'Report results should include proper ratings'
    end

    it 'returns empty results by default' do
      expect(report.data).to be_empty
    end

    it 'returns empty results when no movies are found' do
      expect_movies_in_source []

      report.build!
      expect(report.data).to be_empty
    end

    def expect_movies_in_source(data)
      FakeSearchEngine.any_instance.stubs(:all_movies).returns(data)
      data
    end

    def expect_run_strategy(strategy)
      MoviesReport.strategies[strategy].any_instance.expects(:run)
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
