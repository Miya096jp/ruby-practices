#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'lib/marks_parser'
require_relative 'lib/game'
require_relative 'lib/frame'
require_relative 'lib/final_frame'
require_relative 'lib/shot'

marks = Marks.new(ARGV[0])
all_frame_instances = marks.parse
game = Game.new(all_frame_instances)
puts game.calc_score
