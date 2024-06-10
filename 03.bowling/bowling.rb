#!/usr/bin/env ruby

# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

FULL_SCORE = 10

shots = []
scores.map do |s|
  if s == 'X'
    shots << FULL_SCORE
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

frames[9..] = [frames[9..].each do |frame|
  frame.delete_at 1 if frame[0] == FULL_SCORE
end.flatten]

point = 0

def strike_shot(frames, idx)
  case idx
  when 0..7
    frames[idx + 1][0] == FULL_SCORE ? 20 + frames[idx + 2][0] : FULL_SCORE + frames[idx + 1].sum
  when 8
    frames[idx][0] + frames[9][0..1].sum
  else
    frames[idx].sum
  end
end

def score_shot(frames, idx)
  frames[idx].sum + frames[idx + 1][0]
end

frames.each.with_index do |frame, idx|
  point += if frame[0] == FULL_SCORE 
             strike_shot(frames, idx)
           elsif frame.sum == FULL_SCORE
             score_shot(frames, idx)
           else
             frame.sum
           end
end

p point
