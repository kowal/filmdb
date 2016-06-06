# coding: utf-8

require 'spec_helper'

describe FilmDb::Strategy::Background do
  context '#current_result' do
    before do
      stub_film_rating 1,  'title' => 'MovieA', 'state' => 'finished', 'rating' => '5.0'
      stub_film_rating 2,  'title' => 'MovieA', 'state' => 'finished', 'rating' => '10.0'
      stub_film_rating 5,  'title' => 'MovieA', 'state' => 'finished', 'rating' => '6.5'
      stub_film_rating 10, 'title' => 'MovieB', 'state' => 'finished', 'rating' => '2.0'
      stub_film_rating 20, 'title' => 'MovieB', 'state' => 'started', 'rating' => '3.0'
      stub_film_rating 50, 'title' => 'MovieB', 'state' => 'started', 'rating' => '10.0'
    end

    it 'returns current average ratings for each movie' do
      results = subject.current_result([1, 2, 5, 10, 20, 50])

      expect(results).to include('MovieA' => 7.2, 'MovieB' => 5.0)
    end

    it 'returns status count per each status' do
      results = subject.current_result([1, 2, 5, 10, 20, 50])

      expect(results).to include(status: { started: 2, finished: 4 })
    end

    it 'returns empty hash when state is blank' do
      stub_film_rating 100, 'state' => nil

      expect(subject.current_result([100])).to eq({})
    end
  end

  def stub_film_rating(worker_id, results)
    FilmDb::WebSearchWorker
      .stubs(:get_worker_data)
      .with(worker_id)
      .returns(results)
  end
end
