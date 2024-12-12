# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/shot'

class TestShot < Minitest::Test
  def test_regular_shot
    shot = Shot.new('5')
    assert_equal 5, shot.score
  end

  def test_strike_shot
    shot = Shot.new('X')
    assert_equal 10, shot.score
  end
end
