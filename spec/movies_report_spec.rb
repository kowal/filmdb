# coding: utf-8

require 'spec_helper'

describe MoviesReport do

  context 'run on chomikuj page' do

    it "should find movies included in the page" do
      subject.parse_html 'http://chomikuj.pl/SHREC'

      expect(subject.movies).to include 'Młody Einstein--orginalny lektor.pl.avi'
    end

  end
end
