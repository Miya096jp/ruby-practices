# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :next_frame, :first_shot, :second_shot

  def initialize(first_shot, second_shot = nil, next_frame: nil)
    @first_shot = first_shot
    @second_shot = second_shot
    @next_frame = next_frame
  end

  def final_frame?
    false
  end

  def strike?
    @first_shot.score == 10
  end

  def spare?
    !strike? && frame_sum == 10
  end

  def frame_sum
    [@first_shot, @second_shot].sum { |shot| shot.nil? ? 0 : shot.score }
  end

  def score
    frame_sum + add_bonus
  end

  def add_bonus
    if strike?
      bonus_for_strike
    elsif spare?
      bonus_for_spare
    else
      0
    end
  end

  def bonus_for_strike
    next_two_shots
  end

  def next_two_shots
    if @next_frame.final_frame?
      @next_frame.bonus_for_strike
    elsif @next_frame.strike?
      @next_frame.first_shot.score + @next_frame.next_frame.first_shot.score
    else
      @next_frame.frame_sum
    end
  end

  def bonus_for_spare
    next_shot
  end

  def next_shot
    @next_frame.first_shot.score
  end
end
