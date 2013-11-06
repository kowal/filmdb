# coding: utf-8

require 'spec_helper'

describe MoviesReport::Strategy::Background do

  it '#current_result' do
    stub_film_rating 1, 'MovieA', 'finished', 5.0
    stub_film_rating 2, 'MovieA', 'finished', 10.0
    stub_film_rating 5, 'MovieA', 'finished', 6.5
    stub_film_rating 10, 'MovieB', 'finished', 2.0
    stub_film_rating 20, 'MovieB', 'started', 3.0
    stub_film_rating 50, 'MovieB', 'started', 10.0

    expect(subject.current_result([1, 2, 5, 10, 20, 50])).to eq({
        "MovieA" => 7.2,
        "MovieB" => 5.0,
        :status => { :started => 2, :finished => 4 }
      })
  end

  def stub_film_rating(worker_id, title, state, rating)
    MoviesReport::WebSearchWorker.stubs(:get_worker_data)
      .with(worker_id)
      .returns({ "state" => state,
                 "title" => title,
                 "rating" => rating.to_s })
  end

end
