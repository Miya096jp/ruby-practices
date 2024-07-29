#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'debug'

KEYS = %i[lines words bytes name].freeze

opt = OptionParser.new
options = { count_lines: false, count_words: false, count_bytes: false }
opt.on('-l') { |v| options[:count_lines] = v }
opt.on('-w') { |v| options[:count_words] = v }
opt.on('-c') { |v| options[:count_bytes] = v }
opt.parse!(ARGV)

keys_to_keep = []
if !options[:count_lines] && !options[:count_words] && !options[:count_bytes]
  keys_to_keep = %i[lines words bytes name]
else
  keys_to_keep << :lines if options[:count_lines]
  keys_to_keep << :words if options[:count_words]
  keys_to_keep << :bytes if options[:count_bytes]
  keys_to_keep << :name
end

def get_text_counts(file_texts, file_names)
  file_texts.map.with_index do |file_text, idx|
    {
      lines: file_text.count("\n"),
      words: file_text.split(/\s+/).count,
      bytes: file_text.to_s.bytesize,
      name: file_names[idx]
    }
  end
end

def get_total(text_counts)
  total = text_counts.each_with_object({}) do |text_count, hash_for_totaling_values|
    text_count.each do |key, value|
      if key != :name
        hash_for_totaling_values[key] ||= 0
        hash_for_totaling_values[key] += value
      end
    end
    hash_for_totaling_values[:name] = 'total'
  end
  [total]
end

def get_max_lengths(text_counts, keys_to_keep)
  max_lengths = keys_to_keep.map do |key|
    text_counts.map { |text_count| text_count[key].to_s.size }.max
  end
  keys_to_keep.zip(max_lengths).to_h
end

def format_text_counts(text_counts, max_lengths, keys_to_keep)
  text_counts.map do |text_count|
    hash = {}
    keys_to_keep.each do |key|
      hash[key] = if key != :name
                    text_count[key].to_s.rjust(max_lengths[key] >= 7 ? max_lengths[key] : 7)
                  else
                    text_count[:name]
                  end
    end
    hash
  end
end

def render_text_counts(text_counts)
  text_counts.map do |text_count|
    text_count.values.join(' ')
  end.join("\n")
end

def render_total_counts(total_counts)
  total_counts.map do |total_count|
    total_count.values.join(' ')
  end.join("\n")
end

file_names = ARGV
file_texts = if file_names[0]
               file_names.map { |file_name| File.open(file_name, 'r').read }
             else
               [ARGF.readlines.join]
             end

text_counts = get_text_counts(file_texts, file_names)

if file_names.size >= 2
  total = get_total(text_counts)
  max_lengths = get_max_lengths(total, keys_to_keep)

  text_counts = format_text_counts(text_counts, max_lengths, keys_to_keep)
  total_counts = format_text_counts(total, max_lengths, keys_to_keep)
  puts render_text_counts(text_counts)
  puts render_total_counts(total_counts)
else
  max_lengths = get_max_lengths(text_counts, keys_to_keep)
  text_counts = format_text_counts(text_counts, max_lengths, keys_to_keep)
  puts render_text_counts(text_counts)
end
