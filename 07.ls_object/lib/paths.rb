# frozen_string_literal: true

require 'pathname'

class Paths
  def initialize(options)
    @options = options
  end

  # def parse
  #   paths = @options.dot_match? ? Dir.glob('*', File::FNM_DOTMATCH).sort : Dir.glob('*')
  #   reverse(paths)
  # end

  def parse
    paths = @options.dot_match? ? Dir.glob(Pathname('./*'), File::FNM_DOTMATCH).sort : Dir.glob(Pathname('./*'))
    reverse(paths)
  end

  private

  def reverse(paths)
    @options.reverse? ? paths.reverse : paths
  end
end
