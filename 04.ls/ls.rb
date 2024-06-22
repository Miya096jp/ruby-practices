#!/usr/bin/env ruby

# frozen_string_literal: true

all_entries = Dir.entries('.')

def filter_entries(entries_original)
  entries_original.reject do |entry|
    entry =~ /\A\./
  end
end

entries = filter_entries(all_entries)
longest_entry = entries.max { |a, b| a.length <=> b.length }
INTERVAL = longest_entry.length
COLUMN = 3

def find_row(entries, column)
  entries.size.ceildiv(column)
end

row = find_row(entries, COLUMN)

def transpose_entries(entries, column, row)
  entries += [nil] * (column * row - entries.size)
  entries.each_slice(row).to_a.transpose
end

def display_entries(transposed_entries, interval)
  transposed_entries.map do |entries|
    entries.map { |entry| entry&.ljust(interval) }.join
  end.join("\n")
end

transposed_entries = transpose_entries(entries, COLUMN, row)
print transposed_entries
print display_entries(transposed_entries, INTERVAL)
