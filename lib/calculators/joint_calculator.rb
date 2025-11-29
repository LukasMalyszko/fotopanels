# frozen_string_literal: true

require_relative '../models/joint'

module Calculators
  # Calculates joint positions at panel corners
  class JointCalculator
    CORNER_PROXIMITY = 0.5 # Corners within this distance are joined

    def initialize(panels:)
      @panels = panels
    end

    # @return [Array<Models::Joint>]
    def calculate
      joints = []
      seen = Set.new

      @panels.each do |panel|
        # Check all four corners of each panel (excluding top-left which is never interior)
        corners = [
          { x: panel.right_edge, y: panel.y },                # top-right
          { x: panel.x, y: panel.bottom_edge },               # bottom-left
          { x: panel.right_edge, y: panel.bottom_edge }       # bottom-right
        ]

        corners.each do |corner|
          # Check if this corner is shared with at least 1 OTHER panel (making it interior)
          # Count must be >= 2 (current panel + at least 1 other)
          touching_count = count_panels_at_corner(corner)
          next unless touching_count >= 2

          key = [corner[:x].round(2), corner[:y].round(2)]
          unless seen.include?(key)
            joints << Models::Joint.new(x: corner[:x], y: corner[:y])
            seen.add(key)
          end
        end
      end

      merge_nearby_joints(joints)
    end

    private

    # Count how many panels have a corner near this location
    def count_panels_at_corner(corner)
      count = 0

      @panels.each do |panel|
        panel_corners = [
          { x: panel.x, y: panel.y },                    # top-left
          { x: panel.right_edge, y: panel.y },           # top-right
          { x: panel.x, y: panel.bottom_edge },          # bottom-left
          { x: panel.right_edge, y: panel.bottom_edge }  # bottom-right
        ]

        panel_corners.each do |panel_corner|
          distance_x = (corner[:x] - panel_corner[:x]).abs
          distance_y = (corner[:y] - panel_corner[:y]).abs
          if distance_x < CORNER_PROXIMITY && distance_y < CORNER_PROXIMITY
            count += 1
            break # Only count each panel once
          end
        end
      end

      count
    end

    # Merge joints that are very close together (within CORNER_PROXIMITY)
    def merge_nearby_joints(joints)
      return [] if joints.empty?

      merged = []
      used = Set.new

      joints.each_with_index do |joint, i|
        next if used.include?(i)

        # Find all joints near this one
        cluster = [joint]
        cluster_indices = [i]

        joints.each_with_index do |other_joint, j|
          next if i == j || used.include?(j)

          distance_x = (joint.x - other_joint.x).abs
          distance_y = (joint.y - other_joint.y).abs

          if distance_x < CORNER_PROXIMITY && distance_y < CORNER_PROXIMITY
            cluster << other_joint
            cluster_indices << j
          end
        end

        # Mark all joints in this cluster as used
        cluster_indices.each { |idx| used.add(idx) }

        # Use the average position of the cluster
        avg_x = cluster.sum(&:x) / cluster.size
        avg_y = cluster.sum(&:y) / cluster.size
        merged << Models::Joint.new(x: avg_x, y: avg_y)
      end

      merged
    end
  end
end
