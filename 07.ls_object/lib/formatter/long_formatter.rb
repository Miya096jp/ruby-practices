# frozen_string_literal: true

class LongFormatter
  def initialize(file_metadata_list)
    @file_metadata_list = file_metadata_list
  end

  FILETYPE = {
    '1' => 'p',
    '2' => 'c',
    '4' => 'd',
    '6' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }.freeze

  private_constant :FILETYPE

  def parse
    max_size = build_max_size
    "#{build_total_row}\n#{build_body(max_size)}\n"
  end

  private

  def build_max_size
    {
      nlink: @file_metadata_list.map { |file_metadata| file_metadata.nlink.to_s.size }.max,
      username: @file_metadata_list.map { |file_metadata| file_metadata.username.size }.max,
      groupname: @file_metadata_list.map { |file_metadata| file_metadata.groupname.size }.max,
      bytesize: @file_metadata_list.map { |file_metadata| file_metadata.bytesize.to_s.size }.max
    }
  end

  def build_total_row
    total = @file_metadata_list.sum { |file_metadata| file_metadata.blocks.to_i }
    "total: #{total}"
  end

  def build_body(max_size)
    @file_metadata_list.map do |file_metadata|
      [
        "#{format_type(file_metadata)}#{format_mode(file_metadata)}",
        file_metadata.nlink.to_s.rjust(max_size[:nlink] + 1),
        file_metadata.username.rjust(max_size[:username] + 1),
        file_metadata.groupname.rjust(max_size[:groupname] + 1),
        file_metadata.bytesize.to_s.rjust(max_size[:bytesize] + 1),
        " #{format_mtime(file_metadata.mtime)}",
        " #{file_metadata.name}"
      ].join
    end.join("\n")
  end

  def format_type(file_metadata)
    FILETYPE[file_metadata.type]
  end

  def format_mode(file_metadata)
    user, group, others = file_metadata.mode.split('')
    if file_metadata.setuid?
      [SUID_SGID[user], REGULAR_MODE[group], REGULAR_MODE[others]]
    elsif file_metadata.setgid?
      [REGULAR_MODE[user], SUID_SGID[group], REGULAR_MODE[others]]
    elsif file_metadata.sticky?
      [REGULAR_MODE[user], REGULAR_MODE[group], STICKY_BIT[others]]
    else
      [REGULAR_MODE[user], REGULAR_MODE[group], REGULAR_MODE[others]]
    end.join
  end

  def format_mtime(mtime)
    format('%<mon>2d %<mday>2d %<hour>2d:%<min>2d', mon: mtime.mon, mday: mtime.mday, hour: mtime.hour, min: mtime.min)
  end
end
