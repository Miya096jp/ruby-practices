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
    [@first_shot.score, @second_shot.score].sum
  end

  def score
    [@first_shot, @second_shot, @third_shot].sum { |shot| shot.nil? ? 0 : shot.score }
  end
end
