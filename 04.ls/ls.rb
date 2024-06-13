#!/usr/bin/env ruby

# frozen_string_literal: true

all_entries = Dir.entries('.')

def filter_entries(entries_original)
  entries_original.reject do |entry|
    entry == '.' || entry == '..' || entry =~ /^\./
  end
end

entries = filter_entries(all_entries)
column = 3

def find_row(entries, column)
  (entries.size % column).zero? ? entries.size / column : entries.size / column + 1
end

row = find_row(entries, column)

def transpose_entries(entries, column, row)
  entries += [nil] * (column * row - entries.size)
  entries.each_slice(row).to_a.transpose
end

def display_entries(transposed_entries)
  transposed_entries.map do |entries|
    entries.map do |entry|
      entry&.ljust(25)
    end.push "\n"
  end.join
end

transposed_entries = transpose_entries(entries, column, row)
print display_entries(transposed_entries)
