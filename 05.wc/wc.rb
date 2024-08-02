#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'debug'

opt = OptionParser.new
options = { count_lines: false, count_words: false, count_bytes: false }
opt.on('-l') { |v| options[:count_lines] = v }
opt.on('-w') { |v| options[:count_words] = v }
opt.on('-c') { |v| options[:count_bytes] = v }
opt.parse!(ARGV)

option_keys = []
if !options[:count_lines] && !options[:count_words] && !options[:count_bytes]
  option_keys = %i[lines words bytes]
else
  option_keys << :lines if options[:count_lines]
  option_keys << :words if options[:count_words]
  option_keys << :bytes if options[:count_bytes]
end

def calculate_text_counts(file_texts, file_names)
  file_texts.map.with_index do |file_text, idx|
    {
      lines: file_text.count("\n"),
      words: file_text.split(/\s+/).count,
      bytes: file_text.to_s.bytesize,
      name: file_names[idx]
    }
  end
end

def calculate_total(text_counts)
  [text_counts.each_with_object({}) do |text_count, counts|
    text_count.each do |key, value|
      if key != :name
        counts[key] ||= 0
        counts[key] += value
      end
    end
  end]
end

def calculate_max_lengths(text_counts, option_keys)
  max_lengths = option_keys.map do |key|
    text_counts.map { |text_count| text_count[key].to_s.size }.max
  end
  option_keys.zip(max_lengths).to_h
end

def format_text_counts(text_counts, max_lengths, option_keys)
  text_counts.map do |text_count|
    hash = {}
    option_keys.each do |key|
      hash[key] = text_count[key].to_s.rjust(max_lengths[key] >= 7 ? max_lengths[key] : 7)
    end
    hash[:name] = text_count[:name]
    hash
  end
end

def format(text_counts, max_lengths, option_keys)
  text_counts = format_text_counts(text_counts, max_lengths, option_keys)
  text_counts.map do |text_count|
    text_count.values.join(' ')
  end.join("\n")
end

file_names = ARGV
file_texts = if file_names[0]
               file_names.map { |file_name| File.open(file_name, 'r').read }
             else
               [ARGF.readlines.join]
             end

text_counts = calculate_text_counts(file_texts, file_names)
total = calculate_total(text_counts)
max_lengths = calculate_max_lengths(total, option_keys)
puts format(text_counts, max_lengths, option_keys)
if file_names.size >= 2
  total[0][:name] = 'total'
  puts format(total, max_lengths, option_keys) if file_names.size >= 2
end
