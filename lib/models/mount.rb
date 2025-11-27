# frozen_string_literal: true

module Models
  # Represents a mount point where a panel attaches to a rafter
  class Mount
    attr_reader :x, :y

    # @param x [Numeric] X-coordinate of the mount
    # @param y [Numeric] Y-coordinate of the mount
    def initialize(x:, y:)
      @x = x.round(2)
      @y = y.round(2)
    end

    # @return [Hash] Hash representation of the mount
    def to_h
      { x: @x, y: @y }
    end

    # @param other [Mount] Another mount
    # @return [Boolean] True if mounts have the same coordinates
    def ==(other)
      other.is_a?(Mount) && @x == other.x && @y == other.y
    end

    alias eql? ==

    def hash
      [@x, @y].hash
    end

    def to_s
      "Mount(x=#{@x}, y=#{@y})"
    end
  end
end
