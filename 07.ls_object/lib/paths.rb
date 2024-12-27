# frozen_string_literal: true

require 'pathname'

class Paths
  attr_reader :paths

  def initialize(pathname, options)
    @pathname = pathname
    @options = options
    @paths = collect_paths
  end

  private

  def collect_paths
    paths = @options.dot_match? ? Dir.glob(@pathname, File::FNM_DOTMATCH).sort : Dir.glob(@pathname)
    reverse(paths)
  end

  def reverse(paths)
    @options.reverse? ? paths.reverse : paths
  end
end
