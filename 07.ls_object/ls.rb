#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pathname'
require 'optparse'
require 'etc'

COLUMN = 3

MODE_TABLE = {
  '0' => '___',
  '1' => '__x',
  '2' => '_w_',
  '3' => '_wx',
  '4' => 'r__',
  '5' => 'r_x',
  '6' => 'rw_',
  '7' => 'rwx'
}

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
  def initialize(path)
    @path = path
    @stat = File::Stat.new(path)
  end

  def name
    File.basename(@path)
  end

  def type_and_mode
    format_type_and_mode(@stat)
  end

  def nlink
    @stat.nlink.to_s
  end

  def username
    Etc.getpwuid(@stat.uid).name
  end

  def groupname
    Etc.getgrgid(@stat.uid).name
  end

  def bytesize
    @stat.size.to_s
  end

  def mtime
    format_mtime(@stat.mtime)
  end

  def blocks
    @stat.blocks
  end

  private

  def format_type_and_mode(stat)
    type = stat.directory? ? 'd' : '-'
    digits = stat.mode.to_s(8)[-3..]
    mode = digits.gsub(/./, MODE_TABLE)
    "#{type}#{mode}"
  end

  def format_mtime(mtime)
    format('%<mon>2d %<mday>2d %<hour>2d:%<min>2d', mon: mtime.mon, mday: mtime.mday, hour: mtime.hour, min: mtime.min)
  end
end

class LsFormatter
  def initialize(entries, options = nil)
    @entries = entries
    @options = options
  end

  def print
    @options.long_format? ? LsLong.new(@entries).print : LsShort.new(@entries).print
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
    (@entries.size.to_f / COLUMN ).ceil
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

  def build_max_size
    {
      nlink: @entries.map { |entry| entry.nlink.size }.max,
      username: @entries.map { |entry| entry.username.size }.max,
      groupname: @entries.map { |entry| entry.groupname.size }.max,
      bytesize: @entries.map { |entry| entry.bytesize.size }.max
    }
  end

  def build_total_row
    total = @entries.sum { |entry| entry.blocks.to_i }
    "total: #{total}"
  end

  def build_body(max_size)
    @entries.map do |entry|
      [
        entry.type_and_mode,
        entry.nlink.rjust(max_size[:nlink] + 1),
        entry.username.rjust(max_size[:username] + 1),
        entry.groupname.rjust(max_size[:groupname] + 1),
        entry.bytesize.rjust(max_size[:bytesize] + 1),
        " #{entry.mtime}",
        " #{entry.name}"
      ].join
    end
  end
end

class Ls
  def self.run
    opts = OptionParser.new
    options = Options.new(opts)
    paths = Paths.new(options, find_input).parse
    entries = paths.map { |path| Entry.new(path) }
    LsFormatter.new(entries, options).print
  end

  def self.find_input
    ARGV[0] || '.'
  end
end

Ls.run
