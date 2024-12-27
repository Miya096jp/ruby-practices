# frozen_string_literal: true

class ShortFormatter
  def initialize(file_metadata_list)
    @file_metadata_list = file_metadata_list
  end

  def format
    entries = justfy_entries
    row = count_row(entries)
    sliced_entries = slice_entries(entries, row)
    "#{transpose(sliced_entries).map { |entry| entry.join.rstrip }.join("\n")}\n"
  end

  private

  def justfy_entries
    max_length = @file_metadata_list.map { |file_metadata| file_metadata.name.size }.max
    @file_metadata_list.map { |file_metadata| file_metadata.name.ljust(max_length + 1) }
  end

  def count_row(entries)
    (entries.size.to_f / COLUMN).ceil
  end

  def slice_entries(entries, row)
    entries.each_slice(row).to_a
  end

  def transpose(sliced_entries)
    sliced_entries[0].zip(*sliced_entries[1..])
  end
end
