# coding: utf-8

require 'spec_helper'

describe FilmDb::Search::Filmweb do

  let(:fake_service) { mock() }
  let(:movie_title) { 'Some Good Movie' }

  let(:filmweb_search) do
    FilmDb::Search::Filmweb.new(movie_title, fake_service)
  end

  context '#rating' do

    it 'returns float for x,x/y format' do
      fake_service
        .expects(:find)
        .with(movie_title)
        .returns({ rating: '7,1/10' })

      expect(filmweb_search.rating).to eq(7.1)
    end

    it 'returns float for x,x format' do
      fake_service
        .expects(:find)
        .with(movie_title)
        .returns({ rating: '5,5' })

      expect(filmweb_search.rating).to eq(5.5)
    end

    it 'returns float for x.x format' do
      fake_service
        .expects(:find)
        .with(movie_title)
        .returns({ rating: '9.9' })

      expect(filmweb_search.rating).to eq(9.9)
    end

  end

end
