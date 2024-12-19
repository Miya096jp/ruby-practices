# frozen_string_literal: true

class Paths
  def initialize(options)
    @options = options
  end

  def parse
    paths = @options.dot_match? ? Dir.glob('*', File::FNM_DOTMATCH).sort : Dir.glob('*')
    reverse(paths)
  end

  private

  def reverse(paths)
    @options.reverse? ? paths.reverse : paths
  end
end
