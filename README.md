# FilmDB

[![Build Status](https://api.travis-ci.org/kowal/filmdb.png)](https://travis-ci.org/kowal/filmdb)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4c2fc0bbe819453e9ae613e41b7b9966)](https://www.codacy.com/app/kowal/filmdb?utm_source=github.com&utm_medium=referral&utm_content=kowal/filmdb&utm_campaign=badger)
[![Dependency Status](https://gemnasium.com/kowal/filmdb.png)](https://gemnasium.com/kowal/filmdb)
[![Coverage Status](https://coveralls.io/repos/kowal/filmdb/badge.png?branch=master)](https://coveralls.io/r/kowal/filmdb?branch=master)
[![Code Climate](https://codeclimate.com/github/kowal/filmdb.png)](https://codeclimate.com/github/kowal/filmdb)
[![Codeship Status for kowal/filmdb](https://www.codeship.io/projects/4f92a8e0-bce3-0130-8880-5ea7310bec9c/status?branch=master)](https://www.codeship.io/projects/4462)
[![PullReview stats](https://www.pullreview.com/github/kowal/filmdb/badges/add-sidekiq.svg?)](https://www.pullreview.com/github/kowal/filmdb/reviews/add-sidekiq)

**This project is work in progress..**

## What is this?

Simple tool for fetching movies stats. Provides CLI app and API to be used in other applications.

The idea is to provide tool which can:

* Fetch movie titles from various Sources
* For each title, fetch ratings from multple Services and calculate averages

## CLI

Run ```movies-report -h``` to see available commands.

```bash
Usage: movies-report [OPTIONS]
    -u, --url URL                    URL with movies to check
    -k, --keep KEEP_CONNECTION       Keep connection until all job are finished
    -j, --job JOB_ID                 Read Status of job
```

### Examples

Run in background

```bash
$ movies-report -u 'http://chomikuj.pl/Lektor.pl'
# [FilmDB] Fetching page ..
# [FilmDB] Building report (background). ..
# [FilmDB] Scheduled job => 109
```

Check job status using ```--job``` flag:
```bash
$ movies-report -j 109
# [FilmDB] Results: (45/60)
# +----------------------------+---------+------+
# | Title                      | Filmweb | Imdb |
# +----------------------------+---------+------+
# | Last Minute                |    -    | 4.3  |
# | Dont Cry                   |    -    |  -   |
# | Jednostka - Entity         |    -    | 6.0  |
# | ...                        |    -    |  -   |
```

To keep alive application process until all results are fetched, use ```--keep``` flag.
Current progres will be visualized (sparks represents ratings for each film).

```bash
$ movies-report -k true -u 'http://chomikuj.pl/Lektor.pl'
# [FilmDB] Fetching page ..
# [FilmDB] Building report (background). Please wait..
# [FilmDB] Fetching stats [59/60] ▁▆▅▁▆▁▁▁▁▁▇▁▇▁▁▁▇▁▁▆▅▆▇▄▁▁▇▆▇▇▆ 98%
#
# +----------------------------+---------+------+
# | Title                      | Filmweb | Imdb |
# +----------------------------+---------+------+
# | Bezpieczna Przystań        |   7.4   |  -   |
# | Last Minute                |   5.2   | 4.3  |
# | ...
```

## API / Design

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
```
