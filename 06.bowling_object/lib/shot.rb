# frozen_string_literal: true

class Shot
  def initialize(shot)
    @shot = shot
  end

  def score
    @shot == 'X' ? 10 : @shot.to_i
  end
end
