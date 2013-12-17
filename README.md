# FilmDB

[![Build Status](https://api.travis-ci.org/kowal/filmdb.png)](https://travis-ci.org/kowal/filmdb)
[![Dependency Status](https://gemnasium.com/kowal/filmdb.png)](https://gemnasium.com/kowal/filmdb)
[![Coverage Status](https://coveralls.io/repos/kowal/filmdb/badge.png?branch=master)](https://coveralls.io/r/kowal/filmdb?branch=master)
[![Code Climate](https://codeclimate.com/github/kowal/filmdb.png)](https://codeclimate.com/github/kowal/filmdb)
[![Codeship Status for kowal/movies_report](https://www.codeship.io/projects/4f92a8e0-bce3-0130-8880-5ea7310bec9c/status?branch=master)](https://www.codeship.io/projects/4462)

Simple tool for building movies report. Work in progress..

## API

  # Blocking:
  
	report = Report.new("http://chomikuj.pl/user/folder", Source::Chomikuj)
	report.build!
	# => [
	#      { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
	#      { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
	#    ]

  # Async (TODO)

    Report.new("http://chomikuj.pl/user/folder", Source::Chomikuj, background: true).build!
    # => JID-40bccfaa8ddfb861777f697a

## CLI

### Run

    bin/movies-report --url 'http://chomikuj.pl/user/folder'
    "Generating movies stats. Please wait..."

    # after couple of minutes you'll see:
    #
    +----------------------------+---------+------+
    |                Movies stats                 |
    +----------------------------+---------+------+
    | Title                      | Filmweb | Imdb |
    +----------------------------+---------+------+
    | Bezpieczna Przystań        |   7.4   |  -   |
    | Last Minute                |   5.2   | 1.3  |
    | Don't Cry                  |    -    |  -   |
    | O Czym Wiedziała Maisie    |    -    |  -   |
    | Jednostka - Entity         |    -    | 0.0  |
    | Baadshah                   |   7.4   | 6.1  |
    | Rapture Palooza            |   4.8   | 5.1  |
    | ...

