# Quick Reference Guide

## Setup & Run Commands

```bash
# 1. Install dependencies
bundle install

# 2. Run the example
ruby example.rb

# 3. Run all tests
bundle exec rspec

# 4. Run tests with detailed output
bundle exec rspec --format documentation

# 5. Use rake tasks
bundle exec rake          # Run tests
bundle exec rake example  # Run example script
```

## Project Files Overview

### Core Implementation
- `lib/solar_panel_calculator.rb` - Main entry point and orchestrator
- `lib/models/panel.rb` - Panel model with adjacency detection methods
- `lib/models/mount.rb` - Mount position data model
- `lib/models/joint.rb` - Joint position data model
- `lib/calculators/mount_calculator.rb` - Mount calculation logic
- `lib/calculators/joint_calculator.rb` - Joint calculation logic

### Tests (43 tests, all passing)
- `spec/solar_panel_calculator_spec.rb` - Integration tests
- `spec/models/panel_spec.rb` - Panel model tests
- `spec/calculators/mount_calculator_spec.rb` - Mount logic tests
- `spec/calculators/joint_calculator_spec.rb` - Joint logic tests

### Usage
- `example.rb` - Demo script with the task's example data
- `README.md` - Complete documentation
- `output.json` - Generated results from example run

## Key API

```ruby
# Basic usage
result = SolarPanelCalculator.calculate(panels_data)

# With custom configuration
result = SolarPanelCalculator.calculate(
  panels_data,
  rafter_spacing: 16,
  first_rafter_x: 0
)

# Result structure
{
  mounts: [{ x: 16.0, y: 35.55 }, ...],
  joints: [{ x: 44.88, y: 35.55 }, ...]
}
```

## Business Rules Implemented

### Mounts
✅ Aligned with rafters (16 unit spacing)
✅ Edge clearance (≥2 units from panel edges)
✅ Cantilever limit (≤16 units from first/last support to edge)
✅ Span limit (≤48 units between consecutive supports)

### Joints
✅ Horizontal connections (gap <1 unit)
✅ Vertical connections (gap <1 unit)
✅ Corner joints (4-panel intersections)
✅ Unique positions only

## Test Coverage

- ✅ Input validation
- ✅ Edge cases (single panel, adjacent panels, grids)
- ✅ Business rule compliance
- ✅ Custom configurations
- ✅ Error handling
- ✅ Integration scenarios
