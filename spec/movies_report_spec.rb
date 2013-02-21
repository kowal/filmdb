# coding: utf-8

require 'spec_helper'

describe MoviesReport do
  context 'run on chomikuj page' do
    it "should find movies included in the page" do
      VCR.use_cassette('chomikuj') do
        movies_collection = MoviesReport::DSL.parse_html 'http://chomikuj.pl/SHREC'
        expected = <<-DOC
Lot
OCZY SMOKA
Straznicy marzen
Miami Vice
Mama
The Baytown Outlaws
Bez hamulców
Zjawy
Zemsta Po Śmierci
SKYFALL
Nędznicy
Dziewczyna z Sushi
Savages - Poza Bezprawiem
Ralph Demolka
6 kul - Six Bullets
Step Up 3D
Akademia Wojskowa
11-11-11
Cichy dom
The Tall Man
Bucky Larson. Urodzony gwiazdor
Żona na niby
Nawiedzona narzeczona
Love guru
Młody Einstein
Łatwa Dziewczyna
Poznaj moich spartan
Stare Wygi
Święto piwa
DOC
        expected.split("\n").each do |title|
          expect(movies_collection).to include(title)
        end
      end
    end
  end
end
