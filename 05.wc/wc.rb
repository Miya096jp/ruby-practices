#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'debug'

KEYS = %i[lines words bytes].freeze

opt = OptionParser.new
params = { count_lines: false, count_words: false, count_bytes: false }
opt.on('-l') { |v| params[:count_lines] = v }
opt.on('-w') { |v| params[:count_words] = v }
opt.on('-c') { |v| params[:count_bytes] = v }
opt.parse!(ARGV)

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

# def get_total(text_counts)
#   text_counts.each_with_object({}) do |text_count, total|
#     text_count.each do |key, value|
#       if key != :name
#         total[key] ||= 0
#         total[key] += value
#       end
#     end
#     total[:name] = :total
#   end
# end

# def format_text_counts(text_counts)
#   max_length = KEYS.map do |key|
#     text_counts.map { |text_count| text_count[key].to_s.size }.max
#   end
#   max_lengths = KEYS.zip(max_length).to_h

#   text_counts.map do |text_count|
#     {
#       lines: text_count[:lines].to_s.rjust(max_lengths[:lines] >= 7 ? max_lengths[:lines] : 7),
#       words: text_count[:words].to_s.rjust(max_lengths[:words] >= 7 ? max_lengths[:words] : 7),
#       bytes: text_count[:bytes].to_s.rjust(max_lengths[:bytes] >= 7 ? max_lengths[:bytes] : 7),
#       name: text_count[:name]
#     }
#   end
# end

# def get_total(text_counts)
#   text_counts.each_with_object({}) do |text_count, total|
#     text_count.each do |key, value|
#       if key != :name
#         total[key] ||= 0
#         total[key] += value
#       end
#     end
#     total[:name] = :total
#   end
# end

# binding.break
def format_text_counts(text_counts, file_names)
  if file_names.size >= 2
    text_counts << text_counts.each_with_object({}) do |text_count, total|
      text_count.each do |key, value|
        if key != :name
          total[key] ||= 0
          total[key] += value
        end
      end
      total[:name] = :total
    end
  end

  max_length = KEYS.map do |key|
    text_counts.map { |text_count| text_count[key].to_s.size }.max
  end
  max_lengths = KEYS.zip(max_length).to_h

  text_counts.map do |text_count|
    {
      lines: text_count[:lines].to_s.rjust(max_lengths[:lines] >= 7 ? max_lengths[:lines] : 7),
      words: text_count[:words].to_s.rjust(max_lengths[:words] >= 7 ? max_lengths[:words] : 7),
      bytes: text_count[:bytes].to_s.rjust(max_lengths[:bytes] >= 7 ? max_lengths[:bytes] : 7),
      name: text_count[:name]
    }
  end
end

#KEYS = [:lines, :words, :bytes]

def render(text_counts, count_lines: false, count_words: false, count_bytes: false)
  # KEYS.map do |key|
  #   text_counts.map do |text_count|
  #     text_count[key] 

  #   end
  # end

  text_counts.map do |text_count|
    elements = {
      lines: text_count[:lines],
      words: text_count[:words],
      bytes: text_count[:bytes],
      name: text_count[:name]
    }

    if !count_lines && !count_words && !count_bytes
      elements.values.join(' ')
    else
      elements.delete(:lines) unless count_lines
      elements.delete(:words) unless count_words
      elements.delete(:bytes) unless count_bytes
      elements.values.join(' ')
    end
  end.join("\n")
end

file_names = ARGV
file_texts = if file_names[0]
               file_names.map { |file_name| File.open(file_name, 'r').read }
             else
               [ARGF.readlines.join]
             end
text_counts = get_text_counts(file_texts, file_names)
# text_counts << get_total(text_counts) if file_names.size >= 2
# text_counts = format_text_counts(text_counts)

text_counts = format_text_counts(text_counts, file_names)
puts render(text_counts, **params)
