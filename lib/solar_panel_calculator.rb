# frozen_string_literal: true

require_relative 'models/panel'
require_relative 'models/mount'
require_relative 'models/joint'
require_relative 'calculators/mount_calculator'
require_relative 'calculators/joint_calculator'

# Main service class for calculating solar panel mounts and joints
#
# This service orchestrates the calculation of structural supports (mounts)
# and inter-panel joints for a solar array installation.
#
# @example
#   panels_data = [
#     { x: 0, y: 0 },
#     { x: 45.05, y: 0 }
#   ]
#   result = SolarPanelCalculator.calculate(panels_data)
#   puts result[:mounts]  # => Array of mount positions
#   puts result[:joints]  # => Array of joint positions
class SolarPanelCalculator
  class InvalidInputError < StandardError; end

  PANEL_WIDTH = 44.7
  PANEL_HEIGHT = 71.1

  # Calculate mount and joint positions for the given panel layout
  #
  # @param panels_data [Array<Hash>] Array of panel positions with :x and :y keys
  # @param rafter_spacing [Numeric] Distance between rafters (default: 16)
  # @param first_rafter_x [Numeric] X-coordinate of the first rafter (default: 0)
  # @return [Hash] Hash with :mounts and :joints arrays
  # @raise [InvalidInputError] if input data is invalid
  def self.calculate(panels_data, rafter_spacing: 16, first_rafter_x: 0)
    new(panels_data, rafter_spacing, first_rafter_x).calculate
  end

  def initialize(panels_data, rafter_spacing = 16, first_rafter_x = 0)
    @panels_data = panels_data
    @rafter_spacing = rafter_spacing
    @first_rafter_x = first_rafter_x
    validate_input!
  end

  # Perform the calculation
  #
  # @return [Hash] Hash with :mounts and :joints arrays
  def calculate
    panels = build_panels
    mounts = calculate_mounts(panels)
    joints = calculate_joints(panels)

    {
      mounts: mounts.map(&:to_h),
      joints: joints.map(&:to_h)
    }
  end

  private

  def validate_input!
    raise InvalidInputError, 'panels_data must be an array' unless @panels_data.is_a?(Array)
    raise InvalidInputError, 'panels_data cannot be empty' if @panels_data.empty?

    @panels_data.each_with_index do |panel, index|
      unless panel.is_a?(Hash) && panel.key?(:x) && panel.key?(:y)
        raise InvalidInputError, "Panel at index #{index} must have :x and :y keys"
      end

      unless panel[:x].is_a?(Numeric) && panel[:y].is_a?(Numeric)
        raise InvalidInputError, "Panel at index #{index} coordinates must be numeric"
      end
    end
  end

  def build_panels
    @panels_data.map do |data|
      Models::Panel.new(
        x: data[:x],
        y: data[:y],
        width: PANEL_WIDTH,
        height: PANEL_HEIGHT
      )
    end
  end

  def calculate_mounts(panels)
    calculator = Calculators::MountCalculator.new(
      panels: panels,
      rafter_spacing: @rafter_spacing,
      first_rafter_x: @first_rafter_x
    )
    calculator.calculate
  end

  def calculate_joints(panels)
    calculator = Calculators::JointCalculator.new(panels: panels)
    calculator.calculate
  end
end
