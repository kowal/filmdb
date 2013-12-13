# coding: utf-8

require 'spec_helper'

describe MoviesReport::Report do

  # dumb search engine impl.
  class FakeSearchEngine
    def initialize(url) end
  end

  class FooStrategy
  end

  let(:movies_url) { 'http://does.not.matter.com' }
  let(:search_engine_klass) { FakeSearchEngine }

  context 'create' do

    it 'requires url' do
      # MoviesReport::Report.new
    end

    it 'recognizes search engine' do
      # MoviesReport::Report.register_search 'my.search.engine.pl', FakeSearchEngine
    end
  end

  context 'build' do

    subject(:report) {
      MoviesReport::Report.new url: movies_url, engine: search_engine_klass
    }

    context 'with default strategy' do

      it 'returns results from current strategy' do
        stub_search_engine_results [:search_engine_results]
        stub_strategy_run(:default)
          .with([:search_engine_results])
          .returns([:strategy_results])

        report.build!

        expect(report.data).to eq([:strategy_results])
      end

      it 'returns empty results by default' do
        expect(report.data).to be_empty
      end

      it 'returns empty results when no movies are found' do
        stub_search_engine_results []

        report.build!
        expect(report.data).to be_empty
      end
     
    end

    context 'with custom strategy' do

      it 'should use chosen strategy' do
        stub_search_engine_results [:foo]
        MoviesReport.configure do |config|
          config.register_strategy :foo_strategy, FooStrategy
        end

        stub_strategy_run(:foo_strategy).with([:foo]).returns('foo')

        report.build! :foo_strategy
        expect(report.data).to eq('foo')
      end
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

def stub_search_engine_results(data)
  FakeSearchEngine.any_instance.stubs(:all_movies).returns(data)
  data
end

def stub_strategy_run(strategy)
  MoviesReport.strategies[strategy].any_instance.expects(:run)
end