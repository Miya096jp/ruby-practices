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
    FILETYPE[entry.type]
  end

  def format_mode(entry)
    if entry.setuid?
      [SUID_SGID[entry.user], REGULAR_MODE[entry.group], REGULAR_MODE[entry.others]]
    elsif entry.setgid?
      [REGULAR_MODE[entry.user], SUID_SGID[entry.group], REGULAR_MODE[entry.others]]
    elsif entry.sticky?
      [REGULAR_MODE[entry.user], REGULAR_MODE[entry.group], STICKY_BIT[entry.others]]
    else
      [REGULAR_MODE[entry.user], REGULAR_MODE[entry.group], REGULAR_MODE[entry.others]]
    end.join
  end

  def format_mtime(mtime)
    format('%<mon>2d %<mday>2d %<hour>2d:%<min>2d', mon: mtime.mon, mday: mtime.mday, hour: mtime.hour, min: mtime.min)
  end
end
