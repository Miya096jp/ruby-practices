#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative './lib/options'
require_relative './lib/entry'
require_relative './lib/paths'
require_relative './lib/formatter/ls_formatter'
require_relative './lib/formatter/ls_short'
require_relative './lib/formatter/ls_long'
require 'pathname'

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

class Ls
  def initialize(pathname, options)
    @pathname = pathname
    @options = options
  end

  def run
    paths = parse_paths(@pathname, @options)
    entries = parse_entries(paths)
    ls = select_formatter(entries, @options)
    ls.parse
  end

  private

  def parse_paths(pathname, options)
    Paths.new(pathname, options).parse
  end

  def parse_entries(paths)
    paths.map { |path| Entry.new(path, File::Stat.new(path)) }
  end

  def select_formatter(entries, options)
    options.long_format? ? LsLong.new(entries) : LsShort.new(entries)
  end
end

pathname = Pathname('./*')
options = Options.new(ARGV)
ls = Ls.new(pathname, options)
puts ls.run
