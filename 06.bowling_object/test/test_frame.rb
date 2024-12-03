# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/frame'
require_relative '../lib/shot'
require_relative '../lib/final_frame'

class TestFrame < Minitest::Test
  def test_regular_frame
    frame = Frame.new(Shot.new('6'), Shot.new('3'))
    assert_equal 9, frame.score
  end

  def test_strike_frame
    frame = Frame.new(Shot.new('X'))
    next_frame = Frame.new(Shot.new('7'), Shot.new('3'))
    frame.next_frame = next_frame
    assert_equal 20, frame.score
  end

  def test_spare_frame
    frame = Frame.new(Shot.new('5'), Shot.new('5'))
    next_frame = Frame.new(Shot.new('5'), Shot.new('2'))
    frame.next_frame = next_frame
    assert_equal 15, frame.score
  end
end
