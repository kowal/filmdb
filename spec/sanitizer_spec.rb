# coding: utf-8

require 'spec_helper'

describe MoviesReport::Source::ChomikujSanitizer do

  subject(:sanitizer) { MoviesReport::Source::ChomikujSanitizer }

  context '#clean', req: '959098' do

    context 'with invalid input' do

      it 'requires  title', req: '959098' do
        expect { sanitizer.clean(nil) }.to raise_error ArgumentError
      end

      it 'not fail on blank title', req: '959098' do
        expect(sanitizer.clean('')).to eq('')
      end

    end

    context 'with real examples' do

      let(:expected_titles) do
        YAML.load(File.open('fixtures/sanitizer/chomikuj.yml'))
      end

      # This spec is using chomikuj.yml fixture to verify common cases.
      # Note: This example is required for good refactor later on.
      #
      it 'clear titles as expected' do
        expected_titles.each do |title|
          original_title = title['in']
          expected_title = title['out']

          expect(sanitizer.clean(original_title)).to eq(expected_title)
        end
      end

    end

  end
end
