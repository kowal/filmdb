# coding: utf-8

require 'spec_helper'

describe MoviesReport::Search::Filmweb do

  let(:fake_service) { mock() }
  let(:movie_title) { 'Some Good Movie' }

  let(:filmweb_search) { MoviesReport::Search::Filmweb.new(movie_title, fake_service) }

  context '#rating' do

    it 'returns float for x,x/y format' do
      fake_service.expects(:find).with(movie_title).returns({ rating: '7,1/10' })

      expect(filmweb_search.rating).to eq(7.1)
    end

    it 'returns float for x,x format' do
      fake_service.expects(:find).with(movie_title).returns({ rating: '7,1' })

      expect(filmweb_search.rating).to eq(7.1)
    end

    it 'returns float for x.x format' do
      fake_service.expects(:find).with(movie_title).returns({ rating: '7.1' })

      expect(filmweb_search.rating).to eq(7.1)
    end

  end

end
