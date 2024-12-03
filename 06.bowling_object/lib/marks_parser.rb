# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'final_frame'

class MarksParser
  def initialize(marks)
    @marks = marks
  end

  def parse_marks
    shots = create_shot_instances(@marks)
    frames = group_shots_into_frames(shots)
    regular_frame_instances, final_frame_instance = create_frame_instances(frames)
    link_frames(regular_frame_instances, final_frame_instance)
  end

  def group_shots_into_frames(shots)
    frames = []
    shots.each do |shot|
      frames << [] if frames.size < 10 && next_frame?(frames)
      frames.last << shot
    end
    frames
  end

  def next_frame?(frames)
    rolls = frames.last
    frames.empty? || rolls[0].score == 10 || rolls.size == 2
  end

  def create_shot_instances(marks)
    marks.split(',').map { |shot| Shot.new(shot) }
  end

  def create_frame_instances(frames)
    final_frame = frames.pop
    [create_regular_frame_instances(frames), create_final_frame_instance(final_frame)]
  end

  def create_regular_frame_instances(regular_frames)
    regular_frames.map { |regular_frame| Frame.new(*regular_frame) }
  end

  def create_final_frame_instance(final_frame)
    FinalFrame.new(*final_frame)
  end

  def link_frames(regular_frame_instances, final_frame_instance)
    regular_frame_instances.each_with_index do |regular_frame_instance, idx|
      regular_frame_instance.next_frame = regular_frame_instances[idx + 1]
    end
    regular_frame_instances.last.next_frame = final_frame_instance
    regular_frame_instances + [final_frame_instance]
  end
end
