#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
COLUMN = 3
all_entries = Dir.entries('.').sort

options = ARGV.getopts('r')

def filter_entries(entries_original)
  entries_original.reject do |entry|
    entry.start_with?('.')
  end
end

filtered_entries = filter_entries(all_entries)

entries = options['r'] ? filtered_entries.reverse : filtered_entries

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
puts display_entries(transposed_entries, max_filename_length)
