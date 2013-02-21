# coding: utf-8

require 'spec_helper'

# To update fixtures/expected/*.yml, run following JS in browser:
#
#     $.map($('PATTERN'), function(el, idx) { return $(el).text().trim() })
#
describe MoviesReport do
  context 'run on chomikuj page' do
    it "should find movies included in the page" do
      site = 'chomikuj'

      VCR.use_cassette(site, :record => :new_episodes) do
        expected_movies = YAML::load(File.open("fixtures/expected/chomikuj.yml"))
        report = MoviesReport::DSL.parse_html "http://chomikuj.pl/mocked-page"
        actual_movies = report.map { |m| m[:title] }

        expect(actual_movies).to include(*expected_movies)
      end
    end
  end
end
