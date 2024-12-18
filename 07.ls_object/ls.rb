#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pathname'
require 'optparse'
require 'etc'

COLUMN = 3

FILETYPE = {
  '1' => 'p',
  '2' => 'c',
  '4' => 'd',
  '6' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze

REGULAR_MODE = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

SUID_SGID = {
  '0' => '---',
  '1' => '--s',
  '2' => '-wS',
  '3' => '-ws',
  '4' => 'r-S',
  '5' => 'r-s',
  '6' => 'rwS',
  '7' => 'rws'
}.freeze

STICKY_BIT = {
  '0' => '---',
  '1' => '--t',
  '2' => '-wT',
  '3' => '-wt',
  '4' => 'r-T',
  '5' => 'r-t',
  '6' => 'rwT',
  '7' => 'rwt'
}.freeze

COLUMN = 3

class Options
  def initialize(opts)
    opts.on('-l') { |v| @long_format = v }
    opts.on('-r') { |v| @reverse = v }
    opts.on('-a') { |v| @dot_match = v }
    opts.parse!(ARGV)
  end

  def long_format?
    @long_format
  end

  def reverse?
    @reverse
  end

  def dot_match?
    @dot_match
  end
end

class Paths
  def initialize(options, input)
    @options = options
    @input = input
  end

  def create_pathname
    Pathname(@input)
  end

  def parse
    paths = @options.dot_match? ? Dir.glob(create_pathname.join('*'), File::FNM_DOTMATCH).sort : Dir.glob(create_pathname.join('*'))
    reverse(paths)
  end

  def reverse(paths)
    @options.reverse? ? paths.reverse : paths
  end
end

class Entry
  def initialize(path, stat)
    @path = path
    @stat = stat
  end

  def name
    File.basename(@path)
  end

  def type
    format_type(@stat)
  end

  def mode
    format_mode(@stat)
  end

  def setuid?
    @stat.setuid?
  end

  def setgid?
    @stat.setgid?
  end

  def sticky?
    @stat.sticky?
  end

  def nlink
    @stat.nlink
  end

  def username
    Etc.getpwuid(@stat.uid).name
  end

  def groupname
    Etc.getgrgid(@stat.gid).name
  end

  def bytesize
    @stat.size
  end

  def mtime
    @stat.mtime
  end

  def blocks
    @stat.blocks
  end

  private

  def format_type(stat)
    stat.mode.to_s(8)[..-5]
  end

  def format_mode(stat)
    stat.mode.to_s(8)[-3..]
  end
end

class LsFormatter
  def initialize(entries)
    @entries = entries
  end
end

class LsShort < LsFormatter
  def print
    entries = justfy_entries
    row = count_row
    sliced_entries = slice_entries(entries, row)
    transpose(sliced_entries).each { |entry| puts entry.join }
  end

  private

  def justfy_entries
    max_length = @entries.map { |entry| entry.name.size }.max
    @entries.map { |entry| entry.name.ljust(max_length) }
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

class LsLong < LsFormatter
  def print
    max_size = build_max_size
    puts build_total_row
    puts build_body(max_size)
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
    end
  end

  def format_type(entry)
    digits = entry.type
    digits.gsub(/./, FILETYPE)
  end

  def format_mode(entry)
    digits = entry.mode.split('')
    digits.map.with_index do |digit, index|
      table_for_digits(digit, index, entry)
    end.join
  end

  def table_for_digits(digit, index, entry)
    if index.zero? && entry.setuid?
      SUID_SGID[digit]
    elsif index == 1 && entry.setgid?
      SUID_SGID[digit]
    elsif index == 2 && entry.sticky?
      STICKY_BIT[digit]
    else
      REGULAR_MODE[digit]
    end
  end

  def format_mtime(mtime)
    format('%<mon>2d %<mday>2d %<hour>2d:%<min>2d', mon: mtime.mon, mday: mtime.mday, hour: mtime.hour, min: mtime.min)
  end
end

class Ls
  def self.run
    opts = OptionParser.new
    options = Options.new(opts)
    paths = Paths.new(options, find_input).parse
    entries = paths.map { |path| Entry.new(path, File::Stat.new(path)) }
    LsFormatter.new(entries)
    ls = options.long_format? ? LsLong.new(entries) : LsShort.new(entries)
    ls.print
  end

  def self.find_input
    ARGV[0] || '.'
  end
end

Ls.run
