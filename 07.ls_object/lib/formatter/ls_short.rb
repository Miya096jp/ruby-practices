# frozen_string_literal: true

class LsShort < LsFormatter
  def parse
    entries = justfy_entries
    row = count_row
    sliced_entries = slice_entries(entries, row)
    "#{transpose(sliced_entries).map { |entry| entry.join.rstrip }.join("\n")}\n"
  end

  private

  def justfy_entries
    max_length = @entries.map { |entry| entry.name.size }.max
    @entries.map { |entry| entry.name.ljust(max_length + 1) }
  end

  def count_row
    (@entries.size.to_f / COLUMN).ceil
  end

  def slice_entries(entries, row)
    entries.each_slice(row).to_a
  end

  def transpose(sliced_entries)
    sliced_entries[0].zip(*sliced_entries[1..])
  end
end
