# frozen_string_literal: true

class Game
  def initialize(frames)
    @frames = frames
  end

  def calc_score
    @frames.each.sum(&:score)
  end
end
