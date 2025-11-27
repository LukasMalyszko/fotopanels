# Solar Panel Mount and Joint Calculator

A Ruby service for calculating structural support (mount) and inter-panel joint positions for solar panel arrays.

## Overview

This application solves the problem of determining where to place:
- **Mounts**: Structural supports that attach panels to rafters
- **Joints**: Connectors between adjacent panels

The solution follows SOLID principles with a modular, extensible architecture.

## Features

- ✅ Calculates mount positions aligned with rafters
- ✅ Respects edge clearance, cantilever, and span constraints
- ✅ Identifies horizontal and vertical panel adjacencies
- ✅ Supports multi-row grid layouts with shared corner joints
- ✅ Comprehensive test coverage with RSpec
- ✅ Clean, documented, and extensible code

## Technical Specifications

### Constants
- **Panel Width**: 44.7 units
- **Panel Height**: 71.1 units
- **Rafter Spacing**: 16 units (configurable)
- **Edge Clearance**: 2 units (minimum distance from panel edge)
- **Cantilever Limit**: 16 units (maximum overhang from first/last support)
- **Span Limit**: 48 units (maximum distance between consecutive supports)
- **Joint Gap Threshold**: 1 unit (maximum gap for panel adjacency)

## Installation

### Prerequisites
- Ruby 2.7 or higher
- Bundler

### Setup

1. **Clone the repository**
   ```bash
   cd /home/lukasz/Projects/fotopanels
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

## Usage

### Running the Example

The `example.rb` script demonstrates the calculator with the provided test data:

```bash
ruby example.rb
```

This will:
- Calculate mounts and joints for a 10-panel layout
- Display results in the terminal
- Save results to `output.json`

### Using in Your Code

```ruby
require_relative 'lib/solar_panel_calculator'

# Define panel positions (top-left corners)
panels_data = [
  { x: 0, y: 0 },
  { x: 45.05, y: 0 },
  { x: 90.1, y: 0 }
]

# Calculate mounts and joints
result = SolarPanelCalculator.calculate(panels_data)

# Access results
puts "Mounts: #{result[:mounts]}"
puts "Joints: #{result[:joints]}"
```

### Custom Configuration

```ruby
result = SolarPanelCalculator.calculate(
  panels_data,
  rafter_spacing: 20,      # Custom rafter spacing
  first_rafter_x: 5        # Custom first rafter position
)
```

## Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run with detailed output
```bash
bundle exec rspec --format documentation
```

### Run specific test file
```bash
bundle exec rspec spec/solar_panel_calculator_spec.rb
```

### Run with coverage (if configured)
```bash
bundle exec rspec --format progress
```

## Project Structure

```
fotopanels/
├── lib/
│   ├── solar_panel_calculator.rb    # Main service class
│   ├── models/
│   │   ├── panel.rb                 # Panel model
│   │   ├── mount.rb                 # Mount model
│   │   └── joint.rb                 # Joint model
│   └── calculators/
│       ├── mount_calculator.rb      # Mount position logic
│       └── joint_calculator.rb      # Joint position logic
├── spec/
│   ├── solar_panel_calculator_spec.rb
│   ├── models/
│   │   └── panel_spec.rb
│   ├── calculators/
│   │   ├── mount_calculator_spec.rb
│   │   └── joint_calculator_spec.rb
│   └── spec_helper.rb
├── example.rb                        # Example usage script
├── Gemfile                          # Dependencies
└── README.md                        # This file
```

## Architecture

### Design Principles

The solution follows **SOLID principles**:

- **Single Responsibility**: Each class has one clear purpose
  - `SolarPanelCalculator`: Orchestrates the calculation
  - `MountCalculator`: Handles mount position logic
  - `JointCalculator`: Handles joint position logic
  - `Panel`, `Mount`, `Joint`: Simple data models

- **Open/Closed**: Extensible through inheritance/composition
- **Liskov Substitution**: Models can be extended without breaking contracts
- **Interface Segregation**: Clean, focused public APIs
- **Dependency Inversion**: Depends on abstractions (models), not concretions

### Key Classes

#### `SolarPanelCalculator`
Main service that validates input and coordinates calculations.

**Public API:**
- `calculate(panels_data, rafter_spacing: 16, first_rafter_x: 0)` → Returns `{ mounts: [...], joints: [...] }`

#### `Models::Panel`
Represents a solar panel with position and dimension data. Provides helper methods for adjacency detection.

#### `Calculators::MountCalculator`
Calculates mount positions based on:
- Rafter alignment
- Edge clearance constraints
- Cantilever limits
- Span limits

#### `Calculators::JointCalculator`
Identifies and positions joints for:
- Horizontal adjacencies (side-by-side panels)
- Vertical adjacencies (stacked panels)
- Corner connections (4-panel intersections)

## Algorithm Details

### Mount Calculation
1. For each panel, find all rafters within bounds (respecting edge clearance)
2. Select rafters to satisfy constraints:
   - First/last mount within cantilever limit from edges
   - No two consecutive mounts exceed span limit
3. Place mounts at vertical center of panel

### Joint Calculation
1. **Horizontal joints**: Check all panel pairs for horizontal adjacency
2. **Vertical joints**: Check all panel pairs for vertical adjacency
3. **Corner joints**: Identify points where 4 panels meet
4. Deduplicate to return unique positions

## Example Output

```json
{
  "mounts": [
    { "x": 16.0, "y": 35.55 },
    { "x": 32.0, "y": 35.55 },
    { "x": 64.0, "y": 35.55 }
  ],
  "joints": [
    { "x": 44.88, "y": 35.55 },
    { "x": 89.93, "y": 35.55 }
  ]
}
```

## Error Handling

The calculator validates input and raises `SolarPanelCalculator::InvalidInputError` for:
- Non-array input
- Empty panel list
- Missing x or y coordinates
- Non-numeric coordinate values

## Testing

Comprehensive test suite covering:
- ✅ Valid input scenarios
- ✅ Edge cases (single panel, adjacent panels, grid layouts)
- ✅ Invalid input handling
- ✅ Custom configurations
- ✅ Constraint satisfaction (edge clearance, cantilever, span limits)
- ✅ Unique position guarantees

## License

This project is provided as-is for evaluation purposes.

## Author

Created as a solution to the Solar Panel Calculator backend development task.
