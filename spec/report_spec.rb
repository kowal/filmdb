# coding: utf-8

require 'spec_helper'

describe FilmDb::Report do

  # fake registered source
  class FakeSearchEngine
    def initialize(url) end
  end
  FilmDb.register_source 'http://fake-search-engine.com', FakeSearchEngine

  # fake unregistered source
  class GreateMoviesSource
    def initialize(url) end
  end

  # fake unregistered source
  class FooSource
    def initialize(url) end
  end

  class FooStrategy; end

  let(:movies_url) { 'http://fake-search-engine.com/top-movies/page/1' }
  let(:search_engine_klass) { FakeSearchEngine }

  context 'create' do

    it 'requires url' do
      expect { FilmDb::Report.new({}) }.to raise_error ArgumentError
    end

    it 'recognizes registered source' do
      FilmDb.register_source 'http://greatmovies.pl', GreateMoviesSource
      report = FilmDb::Report.new url: 'http://greatmovies.pl/latest/movies'

      expect(report.movies_source).to be_instance_of(GreateMoviesSource)
    end

    it 'fails when non-registered source is used' do
      expect {
        FilmDb::Report.new url: 'www.this.wasnt.registered.com/latest/movies'
      }.to raise_error ArgumentError
    end

    it 'allows to provide custom source' do
      report = FilmDb::Report.new url: 'www.foo2000.com/latest/movies', engine: FooSource

      expect(report.movies_source).to be_instance_of(FooSource)
    end

  end

  context 'build' do

    subject(:report) { FilmDb::Report.new url: movies_url, engine: search_engine_klass }
    let(:search_results) { [{ title: :search_engine_results }] }

    context 'with default strategy' do

      it 'returns results from current strategy' do
        # stub some 'search results'
        stub_search_engine_results(search_results)
        # we're expecting that 'default' strategy will receive
        # those 'search results' and returns its own
        stub_strategy_run(:default)
          .with(search_results)
          .returns([:strategy_results])

        report.build!

        expect(report.results).to eq([:strategy_results])
      end

      it 'returns empty results by default' do
        expect(report.results).to be_empty
      end

      it 'returns empty results when no movies are found' do
        stub_search_engine_results []

        report.build!

        expect(report.results).to be_empty
      end

      it 'raises BuildError on any exception' do
        report.stubs(:extract_movie_list).raises(StandardError)

        expect { report.build! }.to raise_error FilmDb::Report::BuildError
      end
     
    end

    context 'with custom strategy' do

      it 'should use chosen strategy' do
        stub_search_engine_results search_results
        FilmDb.configure do |config|
          config.register_strategy :foo_strategy, FooStrategy
        end

        stub_strategy_run(:foo_strategy)
          .with(search_results)
          .returns('foo')

        report.build! :foo_strategy
        expect(report.results).to eq('foo')
      end

    end

  end

  context 'run on real page' do

    it 'finds all movies included in the page', req: '958909' do

      VCR.use_cassette('chomikuj', record: :new_episodes) do
        expected_movies = expected_results_for_site('chomikuj')

        report = FilmDb::Report.new({
          engine: FilmDb::Source::Chomikuj,
          url:    'http://chomikuj.pl/mocked-page'
        })

        actual_output = capture_stdout { report.build! }

        # check movies titles
        actual_movies = report.results.map { |m| m[:title] }
        expect(actual_movies).to include(*expected_movies)

        # check output for default strategy (dots)
        expect(actual_output).to match('.........')
      end
    end

  end

end

def stub_search_engine_results(data)
  FakeSearchEngine.any_instance.stubs(:all_movies).returns(data)
  data
end

def stub_strategy_run(strategy)
  FilmDb.strategies[strategy].any_instance.expects(:run)
end