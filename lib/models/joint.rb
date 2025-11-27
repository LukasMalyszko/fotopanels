# frozen_string_literal: true

module Models
  # Represents a joint connector between panels
  class Joint
    attr_reader :x, :y

    # @param x [Numeric] X-coordinate of the joint center
    # @param y [Numeric] Y-coordinate of the joint center
    def initialize(x:, y:)
      @x = x.round(2)
      @y = y.round(2)
    end

    # @return [Hash] Hash representation of the joint
    def to_h
      { x: @x, y: @y }
    end

    # @param other [Joint] Another joint
    # @return [Boolean] True if joints have the same coordinates
    def ==(other)
      other.is_a?(Joint) && @x == other.x && @y == other.y
    end

    alias eql? ==

    def hash
      [@x, @y].hash
    end

    def to_s
      "Joint(x=#{@x}, y=#{@y})"
    end
  end
end
