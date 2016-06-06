# coding: utf-8

require 'spec_helper'

describe FilmDb::HtmlPage do
  subject(:page) { described_class.new(URI('http://google.pl')) }

  # see https://github.com/sparklemotion/nokogiri/blob/master/lib/nokogiri/html/document.rb
  #
  unless RUBY_PLATFORM == 'java'
    it 'returns document content from URI' do
      with_expected_http_response do |expected_response_body|
        expect(page.document.inner_html.downcase.gsub(/\s+/, '')).to eq(expected_response_body.downcase)
      end
    end

    it 'not fail when URL is given' do
      with_expected_http_response do |expected_response_body|
        page = described_class.new('http://google.pl')
        expect(page.document.inner_html.downcase.gsub(/\s+/, '')).to eq(expected_response_body.downcase)
      end
    end
  end

  private

  def with_expected_http_response
    VCR.use_cassette('google', record: :new_episodes) do
      expected_response_body = expected_results_for_site('google')[0]
      yield(expected_response_body)
    end
  end
end
