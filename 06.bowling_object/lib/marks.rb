# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'final_frame'

class Marks
  def initialize(marks)
    @marks = marks
  end

  def parse
    shots = create_shot_instances(@marks)
    frames = group_shots_into_frames(shots)
    create_frame_instances(frames)
  end

  private

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
    final_frame_instance = create_final_frame_instance(final_frame)
    regular_frame_instances = create_regular_frame_instances(frames, final_frame_instance)
    regular_frame_instances + [final_frame_instance]
  end

  def create_regular_frame_instances(regular_frames, final_frame_instance)
    next_frame = final_frame_instance
    regular_frames.reverse.map do |regular_frame|
      current_frame = Frame.new(*regular_frame, next_frame:)
      next_frame = current_frame
      current_frame
    end.reverse
  end

  def create_final_frame_instance(final_frame)
    FinalFrame.new(*final_frame)
  end
end
