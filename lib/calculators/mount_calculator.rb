# frozen_string_literal: true

require_relative '../models/mount'

module Calculators
  # Calculates mount positions for solar panels based on rafter alignment
  # and structural constraints
  class MountCalculator
    EDGE_CLEARANCE = 2      # Minimum distance from panel edge
    CANTILEVER_LIMIT = 16   # Maximum overhang from first/last support
    SPAN_LIMIT = 48         # Maximum distance between consecutive supports

    # @param panels [Array<Models::Panel>] Array of panel objects
    # @param rafter_spacing [Numeric] Distance between rafters
    # @param first_rafter_x [Numeric] X-coordinate of the first rafter
    # @raise [ArgumentError] if inputs are invalid
    def initialize(panels:, rafter_spacing:, first_rafter_x:)
      raise ArgumentError, 'panels must be an array' unless panels.is_a?(Array)
      raise ArgumentError, 'rafter_spacing must be positive' unless rafter_spacing.is_a?(Numeric) && rafter_spacing > 0
      raise ArgumentError, 'first_rafter_x must be numeric' unless first_rafter_x.is_a?(Numeric)

      @panels = panels
      @rafter_spacing = rafter_spacing
      @first_rafter_x = first_rafter_x
    end

    # Calculate all mount positions
    #
    # @return [Array<Models::Mount>] Array of mount objects
    def calculate
      mounts = []

      # Group panels by row (same y coordinate)
      panels_by_row = @panels.group_by(&:y)

      panels_by_row.each do |_y, row_panels|
        # Sort panels by x position to identify first and last in row
        sorted_panels = row_panels.sort_by(&:x)

        sorted_panels.each_with_index do |panel, index|
          is_last_in_row = (index == sorted_panels.size - 1)
          panel_mounts = calculate_mounts_for_panel(panel, is_last_in_row)
          mounts.concat(panel_mounts)
        end
      end

      deduplicate_mounts(mounts)
    end

    private

    # Remove duplicate mounts and merge mounts that are very close together
    def deduplicate_mounts(mounts)
      return [] if mounts.empty?

      # Group mounts by x coordinate (same rafter)
      by_rafter = mounts.group_by { |m| m.x.round(2) }

      unique_mounts = []
      by_rafter.each do |_x, rafter_mounts|
        # Sort by y coordinate
        sorted = rafter_mounts.sort_by(&:y)

        # Keep first mount
        unique_mounts << sorted.first

        # For remaining mounts, only add if they're far enough from previous
        sorted[1..].each do |mount|
          last_y = unique_mounts.last.y
          # Only add if more than 1 unit away from the last mount on this rafter
          unique_mounts << mount if (mount.y - last_y).abs > 1.0
        end
      end

      unique_mounts
    end

    # Calculate mounts for a single panel
    #
    # @param panel [Models::Panel] The panel to calculate mounts for
    # @param is_last_in_row [Boolean] Whether this is the last panel in the row
    # @return [Array<Models::Mount>] Array of mounts for this panel
    def calculate_mounts_for_panel(panel, is_last_in_row = false)
      available_rafters = find_available_rafters(panel)
      return [] if available_rafters.empty?

      selected_rafters = select_rafters_for_panel(panel, available_rafters, is_last_in_row)

      mounts = []

      # Create mounts at both top and bottom edges of the panel
      selected_rafters.each do |rafter_x|
        mounts << Models::Mount.new(x: rafter_x, y: panel.y)
        mounts << Models::Mount.new(x: rafter_x, y: panel.bottom_edge)
      end

      mounts
    end

    # Find all rafters that intersect with the panel (with edge clearance)
    #
    # @param panel [Models::Panel] The panel
    # @return [Array<Float>] Array of rafter x-coordinates
    def find_available_rafters(panel)
      min_x = panel.x + EDGE_CLEARANCE
      max_x = panel.right_edge - EDGE_CLEARANCE

      rafters = []
      rafter_x = @first_rafter_x

      # Find first rafter that could be in range
      if rafter_x < min_x
        steps = ((min_x - rafter_x) / @rafter_spacing).ceil
        rafter_x += steps * @rafter_spacing
      end

      # Collect all rafters within the panel's range
      while rafter_x <= max_x
        rafters << rafter_x
        rafter_x += @rafter_spacing
      end

      rafters
    end

    # Select which rafters to use for mounts based on constraints
    #
    # @param panel [Models::Panel] The panel
    # @param available_rafters [Array<Float>] Available rafter positions
    # @param is_last_in_row [Boolean] Whether this is the last panel in the row
    # @return [Array<Float>] Selected rafter positions
    def select_rafters_for_panel(_panel, available_rafters, is_last_in_row = false)
      return [] if available_rafters.empty?

      if is_last_in_row
        # Last panel in row gets 2 mounts
        if available_rafters.size >= 2
          [available_rafters.first, available_rafters.last]
        else
          available_rafters
        end
      else
        # Other panels get 1 mount (first available rafter)
        [available_rafters.first]
      end
    end
  end
end
