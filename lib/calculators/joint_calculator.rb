# frozen_string_literal: true

require_relative '../models/joint'

module Calculators
  class JointCalculator
    MAX_GAP = 1.0

    def initialize(panels:)
      @panels = panels
      @joints = []
      @seen = {}
    end

    # @return [Array<Models::Joint>]
    def calculate
      index_panels
      horizontal_joints
      vertical_joints
      four_way_joints
      @joints.uniq
    end

    private

    # Group panels by y and x to speed up adjacency lookups
    def index_panels
      @by_row = @panels.group_by(&:y)
      @by_col = @panels.group_by(&:x)
    end

    # Horizontal adjacency: side-by-side
    def horizontal_joints
      @by_row.each_value do |row|
        row.combination(2).each do |p1, p2|
          next unless (p1.right_edge - p2.x).abs < MAX_GAP ||
                      (p2.right_edge - p1.x).abs < MAX_GAP

          overlap_top    = [p1.y, p2.y].max
          overlap_bottom = [p1.bottom_edge, p2.bottom_edge].min
          next if overlap_bottom <= overlap_top

          joint_x = if p1.x < p2.x
                      (p1.right_edge + p2.x) / 2.0
                    else
                      (p2.right_edge + p1.x) / 2.0
                    end

          joint_y = (overlap_top + overlap_bottom) / 2.0

          add_joint(joint_x, joint_y)
        end
      end
    end

    # Vertical adjacency: stacked panels
    def vertical_joints
      @by_col.each_value do |col|
        col.combination(2).each do |p1, p2|
          next unless (p1.bottom_edge - p2.y).abs < MAX_GAP ||
                      (p2.bottom_edge - p1.y).abs < MAX_GAP

          overlap_left  = [p1.x, p2.x].max
          overlap_right = [p1.right_edge, p2.right_edge].min
          next if overlap_right <= overlap_left

          joint_y = if p1.y < p2.y
                      (p1.bottom_edge + p2.y) / 2.0
                    else
                      (p2.bottom_edge + p1.y) / 2.0
                    end

          joint_x = (overlap_left + overlap_right) / 2.0

          add_joint(joint_x, joint_y)
        end
      end
    end

    # 4-way joints: intersection of 2 horizontal and 2 vertical adjacencies
    def four_way_joints
      # Build a fast lookup of joints placed on horizontal/vertical lines
      joints_by_x = @joints.group_by { |j| j.x.round(3) }
      joints_by_y = @joints.group_by { |j| j.y.round(3) }

      joints_by_x.each do |jx, column|
        joints_by_y.each_key do |jy|
          # If there is a joint on this X and also on this Y,
          # it means horizontal + vertical edges cross → 4-way intersection.
          intersection = column.find { |cj| cj.y.round(3) == jy }
          next unless intersection

          add_joint(jx, jy) # will dedupe automatically
        end
      end
    end

    def add_joint(x, y)
      key = [x.round(3), y.round(3)]
      return if @seen[key]

      @seen[key] = true
      @joints << Models::Joint.new(x: x, y: y)
    end
  end
end
