# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/final_frame'
require_relative '../lib/shot'

class TestFinalFrame < Minitest::Test
  def test_final_frame_score
    finalframe = FinalFrame.new(Shot.new('3'), Shot.new('3'), nil)
    assert_equal 6, finalframe.score
  end

  def test_final_frame_score_with_strike
    finalframe = FinalFrame.new(Shot.new('X'), Shot.new('7'), Shot.new('3'))
    assert_equal 20, finalframe.score
  end

  def test_final_frame_score_with_spare
    finalframe = FinalFrame.new(Shot.new('8'), Shot.new('2'), Shot.new('5'))
    assert_equal 15, finalframe.score
  end
end
