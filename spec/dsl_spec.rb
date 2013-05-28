# coding: utf-8

require 'spec_helper'

# To update fixtures/expected/*.yml, run following JS in browser:
#
#     $.map($('PATTERN'), function(el, idx) { return $(el).text().trim() })
#
describe MoviesReport::DSL do

  context '#report_for' do

    context 'run on chomikuj page' do

      it 'finds all movies included in the page', req: '958909' do

        VCR.use_cassette('chomikuj', record: :new_episodes) do
          expected_movies = expected_results_for_site('chomikuj')

          report = MoviesReport::DSL.report_for 'http://chomikuj.pl/mocked-page'
          actual_movies = report.map { |m| m[:title] }

          expect(actual_movies).to include(*expected_movies)
        end
      end

    end

  end
end
