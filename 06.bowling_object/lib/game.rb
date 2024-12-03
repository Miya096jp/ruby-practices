# frozen_string_literal: true

class Game
  def initialize(all_frame_instances)
    @all_frame_instances = all_frame_instances
  end

  def calc_score
    @all_frame_instances.each.sum(&:score)
  end
end
