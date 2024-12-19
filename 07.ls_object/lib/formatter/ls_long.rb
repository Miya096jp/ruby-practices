# frozen_string_literal: true

class LsLong < LsFormatter
  def parse
    max_size = build_max_size
    "#{build_total_row}\n#{build_body(max_size)}\n"
  end

  private

  def build_max_size
    {
      nlink: @entries.map { |entry| entry.nlink.to_s.size }.max,
      username: @entries.map { |entry| entry.username.size }.max,
      groupname: @entries.map { |entry| entry.groupname.size }.max,
      bytesize: @entries.map { |entry| entry.bytesize.to_s.size }.max
    }
  end

  def build_total_row
    total = @entries.sum { |entry| entry.blocks.to_i }
    "total: #{total}"
  end

  def build_body(max_size)
    @entries.map do |entry|
      [
        "#{format_type(entry)}#{format_mode(entry)}",
        entry.nlink.to_s.rjust(max_size[:nlink] + 1),
        entry.username.rjust(max_size[:username] + 1),
        entry.groupname.rjust(max_size[:groupname] + 1),
        entry.bytesize.to_s.rjust(max_size[:bytesize] + 1),
        " #{format_mtime(entry.mtime)}",
        " #{entry.name}"
      ].join
    end.join("\n")
  end

  def format_type(entry)
    digits = entry.type
    digits.gsub(/./, FILETYPE)
  end

  def format_mode(entry)
    digits = entry.mode.split('')
    digits.map do |digit|
      table_for_permissions(digit, entry)
    end.join
  end

  def table_for_permissions(digit, entry)
    if entry.owner && entry.setuid?
      SUID_SGID[digit]
    elsif entry.group && entry.setgid?
      SUID_SGID[digit]
    elsif entry.others && entry.sticky?
      STICKY_BIT[digit]
    else
      REGULAR_MODE[digit]
    end
  end

  def format_mtime(mtime)
    format('%<mon>2d %<mday>2d %<hour>2d:%<min>2d', mon: mtime.mon, mday: mtime.mday, hour: mtime.hour, min: mtime.min)
  end
end
