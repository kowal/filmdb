# coding: utf-8

require 'spec_helper'


describe MoviesReport::Sanitizer::Chomikuj do
  context 'run all real examples' do
    it "clear titles as expected", :req => 'SAN-1' do
      expected_titles = YAML::load(File.open("fixtures/sanitizer/chomikuj.yml"))

      expected_titles.each do |title|
        original_title = title['in']
        expected_title = title['out']
        sanitized_title = MoviesReport::Sanitizer::Chomikuj.clean(original_title)

        expect(sanitized_title).to eq(expected_title)
      end
    end
  end
end
