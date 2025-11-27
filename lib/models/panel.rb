# frozen_string_literal: true

module Models
  # Represents a solar panel with position and dimensions
  class Panel
    attr_reader :x, :y, :width, :height

    # @param x [Numeric] X-coordinate of the top-left corner
    # @param y [Numeric] Y-coordinate of the top-left corner
    # @param width [Numeric] Width of the panel
    # @param height [Numeric] Height of the panel
    def initialize(x:, y:, width:, height:)
      @x = x.to_f
      @y = y.to_f
      @width = width.to_f
      @height = height.to_f
    end

    # @return [Float] X-coordinate of the right edge
    def right_edge
      @x + @width
    end

    # @return [Float] Y-coordinate of the bottom edge
    def bottom_edge
      @y + @height
    end

    # Check if this panel is horizontally adjacent to another panel
    #
    # @param other [Panel] Another panel
    # @param max_gap [Numeric] Maximum gap to consider adjacent (default: 1)
    # @return [Boolean]
    def horizontally_adjacent?(other, max_gap: 1)
      return false unless overlaps_vertically?(other)

      gap = horizontal_gap(other)
      gap >= 0 && gap < max_gap
    end

    # Check if panels overlap vertically (share Y-range)
    #
    # @param other [Panel] Another panel
    # @return [Boolean]
    def overlaps_vertically?(other)
      !(@y >= other.bottom_edge || other.y >= bottom_edge)
    end

    # Calculate horizontal gap between panels
    #
    # @param other [Panel] Another panel
    # @return [Float] Gap distance (negative if overlapping)
    def horizontal_gap(other)
      if @x < other.x
        other.x - right_edge
      else
        @x - other.right_edge
      end
    end

    # Check if this panel is vertically adjacent to another panel
    #
    # @param other [Panel] Another panel
    # @param max_gap [Numeric] Maximum gap to consider adjacent (default: 1)
    # @return [Boolean]
    def vertically_adjacent?(other, max_gap: 1)
      return false unless overlaps_horizontally?(other)

      gap = vertical_gap(other)
      gap >= 0 && gap < max_gap
    end

    # Check if panels overlap horizontally (share X-range)
    #
    # @param other [Panel] Another panel
    # @return [Boolean]
    def overlaps_horizontally?(other)
      !(@x >= other.right_edge || other.x >= right_edge)
    end

    # Calculate vertical gap between panels
    #
    # @param other [Panel] Another panel
    # @return [Float] Gap distance (negative if overlapping)
    def vertical_gap(other)
      if @y < other.y
        other.y - bottom_edge
      else
        @y - other.bottom_edge
      end
    end

    def to_s
      "Panel(x=#{@x}, y=#{@y}, width=#{@width}, height=#{@height})"
    end
  end
end
