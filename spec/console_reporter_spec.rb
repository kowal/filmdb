# coding: utf-8

require 'spec_helper'

describe MoviesReport::ConsoleReporter do

  let(:report) do
    [ { title: 'A', ratings: { a: nil,   b: nil   } },
      { title: 'B', ratings: { a: nil,   b: '8.0' } },
      { title: 'C', ratings: { a: '',    b: ''    } },
      { title: 'D', ratings: { a: '',    b: '8.0' } },
      { title: 'E', ratings: { a: '9.0', b: '1.0' } },
      { title: 'F', ratings: { a: '6.5', b: '5.0' } } ]
  end

  let(:subject) { MoviesReport::ConsoleReporter.new(report, colorize: false) }

  context '#table_structure' do

    it 'has a single row for each movie' do
      expect(subject.table_structure).to have(report.size).rows
    end

    it 'has all required columns' do
      # title + 2 ratings + avg
      expect(subject.table_structure).to have(4).columns
    end

    it 'does not change titles' do
      table_titles = table_column_values(0)

      expect(table_titles).to match_array(report.map { |m| m[:title] })
    end

    it 'replaces invalid ratings with "-" sign' do
      ratings_for_a = table_column_values(1)
      ratings_for_b = table_column_values(2)

      expect(ratings_for_a).to match_array(%w{ - - - - 9.0 6.5 })
      expect(ratings_for_b).to match_array(%w{ - 8.0 - 8.0 1.0 5.0 })
    end

    def table_column_values(column_index)
      subject.table_structure.rows.map { |row| row[column_index].value }
    end

  end

  context '#display' do

    it 'displays table structure' do
      subject.expects(:table_structure)
      subject.expects(:puts).with(anything)

      subject.display
    end

  end

end
