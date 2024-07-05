#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
COLUMN = 3
CONVERT_FILETYPE = { '1' => 'p', '2' => 'c', '4' => 'd', '6' => 'b', '10' => '-', '12' => 'l', '14' => 's' }.freeze
NORMAL_PERMISSION = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze
SUID_OR_SGID = { '0' => '---', '1' => '--s', '2' => '-wS', '3' => '-ws', '4' => 'r-S', '5' => 'r-s', '6' => 'rwS', '7' => 'rws' }.freeze
STICKY_BIT = { '0' => '---', '1' => '--t', '2' => '-wT', '3' => '-wt', '4' => 'r-T', '5' => 'r-t', '6' => 'rwT', '7' => 'rwt' }.freeze
all_entries = Dir.entries('.').sort

options = ARGV.getopts('l')

def filter_entries(entries_original)
  entries_original.reject do |entry|
    entry.start_with?('.')
  end
end

filtered_entries = filter_entries(all_entries)

longest_entry = filtered_entries.max_by(&:length)
max_filename_length = longest_entry.length

row = filtered_entries.size.ceildiv(COLUMN)

def transpose_entries(entries, column, row)
  entries += [nil] * (column * row - entries.size)
  entries.each_slice(row).to_a.transpose
end

def display_entries(transposed_entries, max_filename_length)
  transposed_entries.map do |entries|
    entries.map { |entry| entry&.ljust(max_filename_length) }.join
  end.join("\n")
end

transposed_entries = transpose_entries(filtered_entries, COLUMN, row)

# ここより以下はlオプションの実装

def convert_filetype(filetype)
  CONVERT_FILETYPE[filetype]
end

def normal_permission(user_type)
  NORMAL_PERMISSION[user_type]
end

def suid_or_sgid(user_type)
  SUID_OR_SGID[user_type]
end

def sticky_bit(user_type)
  STICKY_BIT[user_type]
end

def format_filetype_and_mode(file_stats)
  filetype_and_mode = file_stats.mode.to_s(8)
  filetype = filetype_and_mode[..-5]
  converted_filetype = convert_filetype(filetype)
  permission_type = filetype_and_mode[-4]
  owner = filetype_and_mode[-3]
  group = filetype_and_mode[-2]
  other = filetype_and_mode[-1]

  converted_filetype +
    case permission_type
    when '0'
      normal_permission(owner) + normal_permission(group) + normal_permission(other)
    when '1'
      normal_permission(owner) + normal_permission(group) + sticky_bit(other)
    when '2'
      suid_or_sgid(owner) + normal_permission(group) + normal_permission(other)
    when '4'
      normal_permission(owner) + suid_or_sgid(group) + normal_permission(other)
    end
end

def format_timestamp(file_stats)
  timestamp = file_stats.mtime.to_s
  month = timestamp[5..6]
  date = timestamp[8..9]
  time = timestamp[11..15]
  month[0] = ' ' if month[0] == '0'
  date[0] = ' ' if date[0] == '0'
  month.rjust(3) + date.rjust(3) + time.rjust(6)
end

def convert_file_stats_into_strings(file_stats, entry_names)
  file_stats.each_with_index.map do |file_stat, index|
    [
      format_filetype_and_mode(file_stat),
      file_stat.nlink.to_s,
      Etc.getpwuid(file_stat.uid).name,
      Etc.getgrgid(file_stat.gid).name,
      file_stat.size.to_s,
      format_timestamp(file_stat)
    ] << entry_names[index]
  end
end

def total_blocks(file_stats)
  file_stats.map.sum { |file| file.blocks.to_i }
end

file_stats = filtered_entries.map { |entry| File.stat(entry) }

converted_file_stats = convert_file_stats_into_strings(file_stats, filtered_entries)
total_block_to_display = total_blocks(file_stats)

transposed_file_stats = converted_file_stats.transpose

max_lengths = transposed_file_stats.map.with_index { |file_stat, index| index != 0 ? file_stat.max_by(&:length).length + 1 : file_stat.max_by(&:length).length }

file_stats_to_display =
  transposed_file_stats.map.with_index { |file_stat, index| file_stat.map { _1.rjust(max_lengths[index]) } }.transpose.map(&:join).join("\n")

if options['l']
  puts "total #{total_block_to_display}"
  puts file_stats_to_display
else
  puts display_entries(transposed_entries, max_filename_length)
end
