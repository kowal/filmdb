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

      VCR.use_cassette(site) do
        actual_movies = MoviesReport::DSL.parse_html "http://#{site}.com/mocked-page"
        expected_movies = YAML::load(File.open("fixtures/expected/#{site}.yml"))

        expected_movies.each do |title|
          expect(actual_movies).to include(title)
        end
      end
    end
  end
end
