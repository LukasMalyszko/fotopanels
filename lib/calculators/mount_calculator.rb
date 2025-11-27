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
    def initialize(panels:, rafter_spacing:, first_rafter_x:)
      @panels = panels
      @rafter_spacing = rafter_spacing
      @first_rafter_x = first_rafter_x
    end

    # Calculate all mount positions
    #
    # @return [Array<Models::Mount>] Array of mount objects
    def calculate
      mounts = []

      @panels.each do |panel|
        panel_mounts = calculate_mounts_for_panel(panel)
        mounts.concat(panel_mounts)
      end

      mounts.uniq
    end

    private

    # Calculate mounts for a single panel
    #
    # @param panel [Models::Panel] The panel to calculate mounts for
    # @return [Array<Models::Mount>] Array of mounts for this panel
    def calculate_mounts_for_panel(panel)
      available_rafters = find_available_rafters(panel)
      return [] if available_rafters.empty?

      selected_rafters = select_rafters_for_panel(panel, available_rafters)

      # Create mounts at the center of the panel vertically
      mount_y = panel.y + (panel.height / 2.0)

      selected_rafters.map do |rafter_x|
        Models::Mount.new(x: rafter_x, y: mount_y)
      end
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
    # @return [Array<Float>] Selected rafter positions
    def select_rafters_for_panel(panel, available_rafters)
      return available_rafters if available_rafters.empty?

      selected = [available_rafters.first]

      available_rafters.each do |rafter_x|
        next if selected.include?(rafter_x)

        add_rafter_if_needed(selected, rafter_x, available_rafters, panel)
      end

      ensure_cantilever_satisfied(selected, available_rafters, panel)
      selected.sort
    end

    def add_rafter_if_needed(selected, rafter_x, available_rafters, panel)
      span = rafter_x - selected.last

      return unless span > SPAN_LIMIT || needs_rafter_for_next_span?(rafter_x, selected.last, available_rafters, panel)

      selected << rafter_x
    end

    def needs_rafter_for_next_span?(current_rafter, last_selected, available_rafters, panel)
      remaining = available_rafters.select { |r| r > current_rafter }

      if remaining.empty?
        (panel.right_edge - current_rafter) > CANTILEVER_LIMIT
      else
        (remaining.first - last_selected) > SPAN_LIMIT
      end
    end

    def ensure_cantilever_satisfied(selected, available_rafters, panel)
      right_overhang = panel.right_edge - selected.last
      return unless right_overhang > CANTILEVER_LIMIT
      return if selected.include?(available_rafters.last)

      selected << available_rafters.last
    end
  end
end
