# frozen_string_literal: true

require 'pathname'

class Paths
  def initialize(pathname, options)
    @pathname = pathname
    @options = options
  end

  def parse
    paths = @options.dot_match? ? Dir.glob(@pathname, File::FNM_DOTMATCH).sort : Dir.glob(@pathname)
    reverse(paths)
  end

  private

  def reverse(paths)
    @options.reverse? ? paths.reverse : paths
  end
end
