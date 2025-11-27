#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/solar_panel_calculator'
require 'json'

# Example data from the task
panels_data = [
  { x: 0, y: 0 },
  { x: 45.05, y: 0 },
  { x: 90.1, y: 0 },
  { x: 0, y: 71.6 },
  { x: 135.15, y: 0 },
  { x: 135.15, y: 71.6 },
  { x: 0, y: 143.2 },
  { x: 45.05, y: 143.2 },
  { x: 135.15, y: 143.2 },
  { x: 90.1, y: 143.2 }
]

puts 'Solar Panel Mount and Joint Calculator'
puts '=' * 50
puts "\nInput: #{panels_data.size} panels"
puts "\nPanel dimensions: 44.7 x 71.1"
puts 'Rafter spacing: 16 units'
puts 'First rafter at: x = 0'
puts "\n#{'=' * 50}"

# Calculate mounts and joints
result = SolarPanelCalculator.calculate(
  panels_data,
  rafter_spacing: 16,
  first_rafter_x: 0
)

puts "\n📍 MOUNTS (#{result[:mounts].size} total)"
puts '-' * 50
result[:mounts].sort_by { |m| [m[:y], m[:x]] }.each_with_index do |mount, index|
  puts "  #{index + 1}. x: #{mount[:x].round(2)}, y: #{mount[:y].round(2)}"
end

puts "\n🔗 JOINTS (#{result[:joints].size} total)"
puts '-' * 50
result[:joints].sort_by { |j| [j[:y], j[:x]] }.each_with_index do |joint, index|
  puts "  #{index + 1}. x: #{joint[:x].round(2)}, y: #{joint[:y].round(2)}"
end

puts "\n#{'=' * 50}"
puts "\n💾 Saving results to output.json..."

File.write('output.json', JSON.pretty_generate(result))
puts "✅ Results saved successfully!\n\n"
