#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'lib/marks_parser'
require_relative 'lib/game'
require_relative 'lib/frame'
require_relative 'lib/final_frame'
require_relative 'lib/shot'

marks = Marks.new(ARGV[0])
frames = marks.parse
game = Game.new(frames)
puts game.calc_score
