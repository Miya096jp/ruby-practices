#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative './lib/options'
require_relative './lib/file_metadata'
require_relative './lib/paths'
require_relative './lib/formatter/short_formatter'
require_relative './lib/formatter/long_formatter'
require 'pathname'

class Ls
  def initialize(pathname, options)
    @pathname = pathname
    @options = options
  end

  def run
    paths = collect_paths(@pathname, @options)
    file_metadata_list = build_file_metadata_list(paths)
    formatter = select_formatter(file_metadata_list, @options)
    formatter.format_output
  end

  private

  def collect_paths(pathname, options)
    Paths.new(pathname, options).paths
  end

  def build_file_metadata_list(paths)
    paths.map { |path| FileMetadata.new(path, File::Stat.new(path)) }
  end

  def select_formatter(file_metadata_list, options)
    options.long_format? ? LongFormatter.new(file_metadata_list) : ShortFormatter.new(file_metadata_list)
  end
end

pathname = Pathname('./*')
options = Options.new(ARGV)
ls = Ls.new(pathname, options)
puts ls.run
