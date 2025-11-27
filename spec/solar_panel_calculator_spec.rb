# frozen_string_literal: true

require_relative '../lib/solar_panel_calculator'

RSpec.describe SolarPanelCalculator do
  describe '.calculate' do
    context 'with valid input' do
      let(:panels_data) do
        [
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
      end

      it 'returns a hash with mounts and joints' do
        result = described_class.calculate(panels_data)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:mounts)
        expect(result).to have_key(:joints)
      end

      it 'returns mounts as an array of hashes with x and y coordinates' do
        result = described_class.calculate(panels_data)

        expect(result[:mounts]).to be_an(Array)
        expect(result[:mounts]).not_to be_empty

        result[:mounts].each do |mount|
          expect(mount).to have_key(:x)
          expect(mount).to have_key(:y)
          expect(mount[:x]).to be_a(Numeric)
          expect(mount[:y]).to be_a(Numeric)
        end
      end

      it 'returns joints as an array of hashes with x and y coordinates' do
        result = described_class.calculate(panels_data)

        expect(result[:joints]).to be_an(Array)
        expect(result[:joints]).not_to be_empty

        result[:joints].each do |joint|
          expect(joint).to have_key(:x)
          expect(joint).to have_key(:y)
          expect(joint[:x]).to be_a(Numeric)
          expect(joint[:y]).to be_a(Numeric)
        end
      end

      it 'calculates mounts aligned with rafters' do
        result = described_class.calculate(panels_data, first_rafter_x: 0, rafter_spacing: 16)

        # All mounts should be at rafter positions (multiples of 16)
        result[:mounts].each do |mount|
          expect(mount[:x] % 16).to be_within(0.01).of(0)
        end
      end

      it 'returns unique mount positions' do
        result = described_class.calculate(panels_data)

        mount_positions = result[:mounts].map { |m| [m[:x], m[:y]] }
        expect(mount_positions.uniq.size).to eq(mount_positions.size)
      end

      it 'returns unique joint positions' do
        result = described_class.calculate(panels_data)

        joint_positions = result[:joints].map { |j| [j[:x], j[:y]] }
        expect(joint_positions.uniq.size).to eq(joint_positions.size)
      end
    end

    context 'with simple two-panel layout' do
      let(:panels_data) do
        [
          { x: 0, y: 0 },
          { x: 45.05, y: 0 }
        ]
      end

      it 'creates joints between horizontally adjacent panels' do
        result = described_class.calculate(panels_data)

        # Should have at least one joint between the two panels
        expect(result[:joints].size).to be >= 1

        # Joint should be between the panels horizontally
        joint = result[:joints].first
        expect(joint[:x]).to be > 44.7  # After first panel
        expect(joint[:x]).to be < 45.05 # Before second panel
      end
    end

    context 'with invalid input' do
      it 'raises an error for non-array input' do
        expect do
          described_class.calculate('not an array')
        end.to raise_error(SolarPanelCalculator::InvalidInputError, 'panels_data must be an array')
      end

      it 'raises an error for empty array' do
        expect do
          described_class.calculate([])
        end.to raise_error(SolarPanelCalculator::InvalidInputError, 'panels_data cannot be empty')
      end

      it 'raises an error for panels without x and y keys' do
        expect do
          described_class.calculate([{ x: 0 }])
        end.to raise_error(SolarPanelCalculator::InvalidInputError, /must have :x and :y keys/)
      end

      it 'raises an error for non-numeric coordinates' do
        expect do
          described_class.calculate([{ x: 'zero', y: 0 }])
        end.to raise_error(SolarPanelCalculator::InvalidInputError, /coordinates must be numeric/)
      end
    end

    context 'with custom rafter configuration' do
      let(:panels_data) { [{ x: 10, y: 0 }] }

      it 'accepts custom rafter spacing' do
        result = described_class.calculate(panels_data, rafter_spacing: 20, first_rafter_x: 0)

        expect(result).to have_key(:mounts)
        expect(result[:mounts]).not_to be_empty
      end

      it 'accepts custom first rafter position' do
        result = described_class.calculate(panels_data, rafter_spacing: 16, first_rafter_x: 8)

        # Mounts should be at positions: 8, 24, 40, etc.
        result[:mounts].each do |mount|
          expect((mount[:x] - 8) % 16).to be_within(0.01).of(0)
        end
      end
    end
  end
end
