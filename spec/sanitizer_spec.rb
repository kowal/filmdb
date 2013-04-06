# coding: utf-8

require 'spec_helper'

# To update fixtures/sanitizer/*.yml, run following JS in browser:
#
describe MoviesReport::Sanitizer::Chomikuj do
  context 'run all real examples' do
    it "clear titles as expected" do
      expected_titles = YAML::load(File.open("fixtures/sanitizer/chomikuj.yml"))

      expected_titles.each do |title|
        original_title = title['in']
        expected_title = title['out']
        ap "#{original_title} => #{expected_title}"
        sanitized_title = MoviesReport::Sanitizer::Chomikuj.clean(original_title)

        expect(sanitized_title).to eq(expected_title)
      end
    end
  end
end
