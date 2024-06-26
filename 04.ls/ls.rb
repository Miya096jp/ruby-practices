#!/usr/bin/env ruby

# frozen_string_literal: true

COLUMN = 3
all_entries = Dir.entries('.').sort

def filter_entries(entries_original)
  entries_original.reject do |entry|
    entry.start_with?('.')
  end
end

entries = filter_entries(all_entries)
longest_entry = entries.max_by(&:length)
max_filename_length = longest_entry.length

row = entries.size.ceildiv(COLUMN)

def transpose_entries(entries, column, row)
  entries += [nil] * (column * row - entries.size)
  entries.each_slice(row).to_a.transpose
end

def display_entries(transposed_entries, max_filename_length)
  transposed_entries.map do |entries|
    entries.map { |entry| entry&.ljust(max_filename_length) }.join
  end.join("\n")
end

transposed_entries = transpose_entries(entries, COLUMN, row)
print display_entries(transposed_entries, max_filename_length) + "\n"
