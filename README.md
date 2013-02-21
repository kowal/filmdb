# MoviesReport

Simple tool for building movie report from multiple sources

## Installation

Add this line to your application's Gemfile:

    gem 'movies_report'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install movies_report

## Usage

	report = MoviesReport::DSL.parse_html "http://chomikuj.pl/foo"

	report.first # => { title: 'Foo', links: [..], ratings: [7.7, 8.2, 8.0] }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
