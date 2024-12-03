# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/marks_parser'
require_relative '../lib/game'
require_relative '../lib/shot'
require_relative '../lib/frame'
require_relative '../lib/final_frame'

class TestMarksParser < Minitest::Test
  def test_parse_marks
    test_cases = [
      { input: '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5', expected: 139 },
      { input: '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X', expected: 164 },
      { input: '0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4', expected: 107 },
      { input: '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0', expected: 134 },
      { input: '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8', expected: 144 },
      { input: 'X,X,X,X,X,X,X,X,X,X,X,X', expected: 300 },
      { input: 'X,X,X,X,X,X,X,X,X,X,X,2', expected: 292 },
      { input: 'X,0,0,X,0,0,X,0,0,X,0,0,X,0,0', expected: 50 }
    ]

    test_cases.each do |test_case|
      marks = MarksParser.new(test_case[:input])
      all_frame_instances = marks.parse_marks
      game = Game.new(all_frame_instances)
      assert_equal test_case[:expected], game.calc_score
    end
  end
end
