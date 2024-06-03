#!/usr/bin/env ruby

# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []
scores.map do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

frames[9..] = [frames[9..].each do |frame|
  frame.delete_at 1 if frame[0] == 10
end.flatten]

point = 0

def strike_shot(frames, frame, idx)
  case idx
  when 0..7
    frames[idx + 1][0] == 10 ? 20 + frames[idx + 2][0] : 10 + frames[idx + 1].sum
  when 8
    frame[0] + frames[9][0..1].sum
  else
    frame.sum
  end
end

def score_shot(frames, frame, idx)
  frame.sum + frames[idx + 1][0]
end

def normal_shot(frame, idx)
  if idx == 9
    frame.sum
  elsif frame.sum != 10
    frame.sum
  end
end

frames.each.with_index do |frame, idx|
  point += if frame[0] == 10
             strike_shot(frames, frame, idx)
           elsif frame.sum == 10 && frame[0] != 10
             score_shot(frames, frame, idx)
           else
             normal_shot(frame, idx)
           end
end

p point
