# frozen_string_literal: true

require 'pathname'

class Paths
  attr_reader :paths

  def initialize(pathname, dot_match, reverse)
    @pathname = pathname
    @dot_match = dot_match
    @reverse = reverse
    @paths = collect_paths
  end

  private

  def collect_paths
    paths = @dot_match ? Dir.glob(@pathname, File::FNM_DOTMATCH).sort : Dir.glob(@pathname)
    reverse(paths)
  end

  def reverse(paths)
    @reverse ? paths.reverse : paths
  end
end
