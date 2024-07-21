#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'debug'

def exec
  opt = OptionParser.new
  params = { count_lines: false, count_words: false, count_bytes: false }
  opt.on('-l') { |v| params[:count_lines] = v }
  opt.on('-w') { |v| params[:count_words] = v }
  opt.on('-c') { |v| params[:count_bytes] = v }
  opt.parse!(ARGV)

  ARGV[0] ? process_files(ARGV, **params) : process_stdin(ARGF, **params)
end

def process_files(file_names, **params)
  file_texts = read_files(file_names)
  statistics = compute_statistics(file_texts, **params)
  if file_names.size >= 2
    statistics_with_total = culculate_total(statistics)
    padded_statistics = pad_statistics(statistics_with_total)
  else
    padded_statistics = pad_statistics(statistics)
  end
  statistics_and_file_names = append_names(padded_statistics, file_names)
  puts render_statistics(statistics_and_file_names)
end

def read_files(file_names)
  file_names.map { |file_name| File.open(file_name, 'r').read }
end

def culculate_total(statistics)
  total_statistics = statistics[0].zip(*statistics[1..]).map(&:sum)
  statistics << total_statistics
end

def pad_statistics(statistics)
  padding_list = compute_paddings(statistics)
  statistics.map do |statistic|
    statistic.map.with_index { |element, idx| element.to_s.rjust(padding_list[idx]) }
  end
end

def compute_paddings(statistics)
  max_lengths = statistics[0].zip(*statistics[1..]).map do |each_statistic|
    each_statistic.map(&:to_s).max_by(&:length).length
  end
  max_lengths.map { |max_length| max_length >= 8 ? max_length : 8 }
end

def append_names(padded_statistics, file_names)
  padded_statistics.map.with_index do |padded_statistic, idx|
    padded_statistic << (file_names[idx] || 'total')
  end
end

def process_stdin(argf, **params)
  statistics = compute_statistics([argf.readlines.join], **params)
  padded_statistics = pad_statistics(statistics)
  puts render_statistics(padded_statistics)
end

def compute_statistics(file_texts, count_lines: false, count_words: false, count_bytes: false)
  file_texts.map do |file_text|
    array = []
    array << file_text.count("\n") if count_lines == true
    array << file_text.split(/\s+/).count if count_words == true
    array << file_text.to_s.bytesize if count_bytes == true
    array = default_set(file_text) if array.empty?
    array
  end
end

def default_set(file_text)
  [file_text.count("\n"), file_text.split(/\s+/).count, file_text.to_s.bytesize]
end

def render_statistics(statistics)
  statistics.map do |statistic|
    statistic.join(' ')
  end.join("\n")
end

exec
