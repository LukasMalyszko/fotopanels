# frozen_string_literal: true

require_relative '../models/joint'

module Calculators
  # Calculates joint positions between adjacent solar panels
  class JointCalculator
    MAX_HORIZONTAL_GAP = 1  # Maximum gap for horizontal joints
    MAX_VERTICAL_GAP = 1    # Maximum gap for vertical joints

    # @param panels [Array<Models::Panel>] Array of panel objects
    def initialize(panels:)
      @panels = panels
    end

    # Calculate all joint positions
    #
    # @return [Array<Models::Joint>] Array of unique joint objects
    def calculate
      joints = []

      # Find horizontal joints (side-by-side panels)
      joints.concat(calculate_horizontal_joints)

      # Find vertical joints (stacked panels)
      joints.concat(calculate_vertical_joints)

      # Find corner joints (4-way connections)
      joints.concat(calculate_corner_joints)

      joints.uniq
    end

    private

    # Calculate joints between horizontally adjacent panels
    #
    # @return [Array<Models::Joint>] Horizontal joints
    def calculate_horizontal_joints
      joints = []

      @panels.each do |panel1|
        @panels.each do |panel2|
          next if panel1 == panel2
          next unless panel1.horizontally_adjacent?(panel2, max_gap: MAX_HORIZONTAL_GAP)

          # Joint is placed at the midpoint between panels, vertically centered on overlap
          joint_x = if panel1.x < panel2.x
                      (panel1.right_edge + panel2.x) / 2.0
                    else
                      (panel2.right_edge + panel1.x) / 2.0
                    end

          # Find vertical overlap range
          overlap_top = [panel1.y, panel2.y].max
          overlap_bottom = [panel1.bottom_edge, panel2.bottom_edge].min
          joint_y = (overlap_top + overlap_bottom) / 2.0

          joints << Models::Joint.new(x: joint_x, y: joint_y)
        end
      end

      joints
    end

    # Calculate joints between vertically adjacent panels
    #
    # @return [Array<Models::Joint>] Vertical joints
    def calculate_vertical_joints
      joints = []

      @panels.each do |panel1|
        @panels.each do |panel2|
          next if panel1 == panel2
          next unless panel1.vertically_adjacent?(panel2, max_gap: MAX_VERTICAL_GAP)

          # Joint is placed at the midpoint between panels, horizontally centered on overlap
          joint_y = if panel1.y < panel2.y
                      (panel1.bottom_edge + panel2.y) / 2.0
                    else
                      (panel2.bottom_edge + panel1.y) / 2.0
                    end

          # Find horizontal overlap range
          overlap_left = [panel1.x, panel2.x].max
          overlap_right = [panel1.right_edge, panel2.right_edge].min
          joint_x = (overlap_left + overlap_right) / 2.0

          joints << Models::Joint.new(x: joint_x, y: joint_y)
        end
      end

      joints
    end

    # Calculate corner joints where 4 panels meet
    #
    # @return [Array<Models::Joint>] Corner joints
    def calculate_corner_joints
      joints = []
      processed = Set.new

      @panels.each do |panel|
        # Check bottom-right corner
        corner_x = panel.right_edge
        corner_y = panel.bottom_edge

        # Find panels that share this corner point
        panels_at_corner = find_panels_at_corner(corner_x, corner_y)

        next unless panels_at_corner.size >= 2

        corner_key = [corner_x.round(2), corner_y.round(2)]
        unless processed.include?(corner_key)
          joints << Models::Joint.new(x: corner_x, y: corner_y)
          processed.add(corner_key)
        end
      end

      joints
    end

    # Find all panels that meet at a specific corner point
    #
    # @param x [Float] X-coordinate of the corner
    # @param y [Float] Y-coordinate of the corner
    # @return [Array<Models::Panel>] Panels at this corner
    def find_panels_at_corner(x, y)
      tolerance = 0.5 # Allow small tolerance for corner matching

      @panels.select do |panel|
        # Check if any corner of this panel matches the given point
        corners = [
          [panel.x, panel.y],                           # top-left
          [panel.right_edge, panel.y],                  # top-right
          [panel.x, panel.bottom_edge],                 # bottom-left
          [panel.right_edge, panel.bottom_edge]         # bottom-right
        ]

        corners.any? do |cx, cy|
          (cx - x).abs < tolerance && (cy - y).abs < tolerance
        end
      end
    end
  end
end
