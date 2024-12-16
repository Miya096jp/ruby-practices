#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pathname'
require 'optparse'
require 'debug'

COLUMN = 3

class Options
  def self.parse
    opt = OptionParser.new
    params = { long_format: false, reverse: false, dot_match: false }
    opt.on('-l') { |v| params[:long_format] = v }
    opt.on('-r') { |v| params[:reverse] = v }
    opt.on('-a') { |v| params[:dot_match] = v }
    opt.parse!(ARGV)
    params
  end
end

class Paths
  def initialize(params)
    @reverse = params[:reverse]
    @dot_match = params[:dot_match]
  end

  def detect_path
    ARGV[0] || '.'
  end

  def create_pathname
    Pathname(detect_path)
  end

  def parse
    paths = @dot_match ? Dir.glob(create_pathname.join('*'), File::FNM_DOTMATCH).sort : Dir.glob(create_pathname.join('*'))
    reverse(paths)
  end

  def reverse(paths)
    @reverse ? paths.reverse : paths
  end
end

class LsShort
  def initialize(paths)
    @paths = paths
  end

  def parse
    paths = jusify_paths
    row = count_row
    sliced_paths = slice_paths(paths, row)
    transpose(sliced_paths).each { |a| puts a.join }
  end

  private

  def jusify_paths
    max_length = @paths.map(&:size).max
    @paths.map { |path| path.ljust(max_length) }
  end

  def count_row
    (@paths.size.to_f / COLUMN).ceil
  end

  def slice_paths(paths, row)
    paths.each_slice(row).to_a
  end

  def transpose(sliced_paths)
    sliced_paths[0].zip(*sliced_paths[1..])
  end
end

class Ls
  def self.run
    params = Options.parse
    paths = Paths.new(params).parse
    params[:long_format] ? LsLong.new(paths).parse : LsShort.new(paths).parse
  end
end

Ls.run

class LsLong
end
