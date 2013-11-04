# Movies Report

[![Build Status](https://api.travis-ci.org/kowal/movies_report.png)](https://travis-ci.org/kowal/movies_report)
[![Dependency Status](https://gemnasium.com/kowal/movies_report.png)](https://gemnasium.com/kowal/movies_report)
[![Coverage Status](https://coveralls.io/repos/kowal/movies_report/badge.png?branch=master)](https://coveralls.io/r/kowal/movies_report?branch=master)
[![Code Climate](https://codeclimate.com/github/kowal/movies_report.png)](https://codeclimate.com/github/kowal/movies_report)

Simple tool for building movies report. Provides CLI app and API to be used in other applications.

Work in progress..

## CLI

Run ```movies-report -h``` to see available commands.

```bash
Usage: movies-report [OPTIONS]
    -u, --url URL                    URL with movies to check
    -b, --background BACKGROUND      Run in background
    -k, --keep KEEP_CONNECTION       Keep connection until all job are finished
    -j, --job JOB_ID                 Read Status of job
```


```bash
$ movies-report -b true -k true -u 'http://chomikuj.pl/Lektor.pl'

[FilmDB] Building report. Please wait..
[FilmDB] [59/60] |================================  | 98%

+----------------------------+---------+------+
| Title                      | Filmweb | Imdb |
+----------------------------+---------+------+
| Bezpieczna Przystań        |   7.4   |  -   |
| Last Minute                |   5.2   | 4.3  |
| Dont Cry                   |    -    |  -   |
| Jednostka - Entity         |    -    | 6.0  |
+----------------------------+---------+------+
```

## API

There are also corresponding ways to invoke API directly.

### Normal blocking call

```ruby
report = MoviesReport::Report.new url: "http://chomikuj.pl/user/folder"
report.build!
# ..... (can take several minutes)
report.data
# => [
#      { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
#      { .. }
#    ]
```

### Async call in background

```ruby
report = MoviesReport::Report.new url: "http://chomikuj.pl/user/folder",
                                  background: true
report.build!
# Fast!
report.data
# => [
#      { title: 'MovieC',
#        ratings: {
#           filmweb: '4da97f8f0462cd6c00be0ae4',   # job-ID for Filmweb search
#           imdb:    '9c59bb5667d180be748a68cd' }
#      },
#      { .. }
#    ]

```

## Design

### Core Classes

```ruby
FilmDB          # Main namespace, allows managing Sources, Services and Strategies
FilmDB::Query   # Identifies film from given Source, fetches stats from Services
FilmDB::Source  # Extracts movies list from a web page
FilmDB::Service # Film information back-end, provides ratings, etc.

FilmDB::Strategy # Abstract strategy, defines i-face for running FilmDB::Query
::Simple         # Basic strategy, which queries movies one by one
::Async          # Fetching info about movies is done in background

# FilmDB
FilmDB.register_source 'http://chomikuj.pl',        Source::Chomikuj
FilmDB.register_source 'http://trailers.apple.com', Source::AppleTrailers

FilmDB.register_service :filmweb,  FilmDB::Service::Filmweb
FilmDB.register_service :imdb,     FilmDB::Service::IMDB
FilmDB.register_service :allmovie, FilmDB::Service::AllMovie

FilmDB.register_strategy :default,    FilmDB::Strategy::Simple
FilmDB.register_strategy :background, FilmDB::Strategy::Background

# FilmDB::Query
query = FilmDB::Query.new url: "http://chomikuj.pl/user/folder"
query.source_engine         # => FilmDB::Source::Chomikuj
query.build!                # => [time consuming ...]
query.build!(:background)   # => [much faster ..]
query.results               # => [specific to chosen strategy]

# Use custom Query Strategy
#
# 1. Inherit from FilmDB::Strategy::Base
# 2. Implement #each_film method
# 3. Register it
class BestMoviesStrategy < FilmDB::Strategy::Base
  def each_film(title, service, service_key)
    rating = SomeLib::BestMovies.find(title).rating
    "#{rating} (#{service_key})" # => '5.3 (:best)'
  end
end
FilmDB.register_strategy :best, BestMoviesStrategy

FilmDB::Query.new(@query_options).build!(:best)
# => [ { title: 'Movie A', ratings: { best: '5.3 (:best)', ... } },  ... ]

```
