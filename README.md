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

Building report. Please wait..
[59/60] |================================  | 98%

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
