# frozen_string_literal: true

require_relative 'frame'

class FinalFrame < Frame
  def initialize(first_shot, second_shot, third_shot = nil)
    super(first_shot, second_shot)
    @third_shot = third_shot
  end

  def final_frame?
    true
  end

  def bonus_for_strike
    [@first_shot, @second_shot].sum(&:score)
  end

  def score
    [@first_shot, @second_shot, @third_shot].compact.sum(&:score)
  end
end
