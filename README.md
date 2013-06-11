# Movies Report

[![Build Status](https://api.travis-ci.org/kowal/movies_report.png)](https://travis-ci.org/kowal/movies_report)
[![Dependency Status](https://gemnasium.com/kowal/movies_report.png)](https://gemnasium.com/kowal/movies_report)
[![Coverage Status](https://coveralls.io/repos/kowal/movies_report/badge.png?branch=master)](https://coveralls.io/r/kowal/movies_report?branch=master)
[![Code Climate](https://codeclimate.com/github/kowal/movies_report.png)](https://codeclimate.com/github/kowal/movies_report)

Simple tool for building movies report. Work in progress..

## API
	report = Report.new("http://chomikuj.pl/user/folder", Source::Chomikuj)
	report.build!
	# => [
	#      { title: 'MovieA', ratings: { filmweb: '5.0', imdb: '7.0' } },
	#      { title: 'MovieB', ratings: { filmweb: '6.0', imdb: '8.0' } }
	#    ]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
