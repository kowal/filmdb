# coding: utf-8

require 'spec_helper'


describe MoviesReport::Sanitizer::Chomikuj do

  subject(:sanitizer) { MoviesReport::Sanitizer::Chomikuj }

  context 'with invalid input' do

    it 'require not nil title', :req => [ 'SAN-0',  'OTHER-481' ] do
      expect { sanitizer.clean(nil) }.to raise_error ArgumentError
    end

    it 'not fail on blank title', :req => %w{ SAN-0 } do
      expect(sanitizer.clean('')).to eq('')
    end

  end

  context 'run all real examples' do

    # Desc: This spec is using chomikuj.yml fixture to verify common cases.
    # Note: This example is required for good refactor later on.
    #
    it "clear titles as expected", :req => 'SAN-1' do
      expected_titles = YAML::load(File.open("fixtures/sanitizer/chomikuj.yml"))

      expected_titles.each do |title|
        original_title = title['in']
        expected_title = title['out']

        expect(sanitizer.clean(original_title)).to eq(expected_title)
      end
    end

  end
end
