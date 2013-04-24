# MoviesReport

Simple tool for building movies report. Work in progress..

## Usage

	report = MoviesReport::DSL.report_for "http://chomikuj.pl/foo"

	report.first # => { title: 'Foo', links: [..], ratings: [7.7, 8.2, 8.0] }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
