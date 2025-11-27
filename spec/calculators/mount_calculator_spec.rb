# frozen_string_literal: true

require_relative '../../lib/calculators/mount_calculator'
require_relative '../../lib/models/panel'

RSpec.describe Calculators::MountCalculator do
  describe '#calculate' do
    context 'with a single panel' do
      let(:panel) { Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1) }
      let(:calculator) do
        described_class.new(
          panels: [panel],
          rafter_spacing: 16,
          first_rafter_x: 10
        )
      end

      it 'calculates mounts aligned with rafters' do
        mounts = calculator.calculate

        expect(mounts).not_to be_empty
        mounts.each do |mount|
          expect((mount.x - 10) % 16).to be_within(0.01).of(0)
        end
      end

      it 'places mounts at the vertical center of the panel' do
        mounts = calculator.calculate

        expected_y = panel.y + (panel.height / 2.0)
        mounts.each do |mount|
          expect(mount.y).to be_within(0.01).of(expected_y)
        end
      end

      it 'respects edge clearance constraint' do
        mounts = calculator.calculate

        mounts.each do |mount|
          distance_from_left = mount.x - panel.x
          distance_from_right = panel.right_edge - mount.x

          expect(distance_from_left).to be >= described_class::EDGE_CLEARANCE
          expect(distance_from_right).to be >= described_class::EDGE_CLEARANCE
        end
      end

      it 'respects cantilever limit' do
        mounts = calculator.calculate

        first_mount_x = mounts.min_by(&:x).x
        last_mount_x = mounts.max_by(&:x).x

        left_overhang = first_mount_x - panel.x
        right_overhang = panel.right_edge - last_mount_x

        expect(left_overhang).to be <= described_class::CANTILEVER_LIMIT
        expect(right_overhang).to be <= described_class::CANTILEVER_LIMIT
      end
    end

    context 'with multiple panels' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 0, y: 71.6, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) do
        described_class.new(
          panels: panels,
          rafter_spacing: 16,
          first_rafter_x: 10
        )
      end

      it 'calculates mounts for all panels' do
        mounts = calculator.calculate

        # Should have mounts for each panel
        expect(mounts.size).to be >= panels.size
      end

      it 'returns unique mount positions' do
        mounts = calculator.calculate

        expect(mounts.uniq.size).to eq(mounts.size)
      end
    end

    context 'with custom rafter configuration' do
      let(:panel) { Models::Panel.new(x: 10, y: 0, width: 44.7, height: 71.1) }

      it 'works with custom first rafter position' do
        calculator = described_class.new(
          panels: [panel],
          rafter_spacing: 16,
          first_rafter_x: 8
        )

        mounts = calculator.calculate

        mounts.each do |mount|
          expect((mount.x - 8) % 16).to be_within(0.01).of(0)
        end
      end

      it 'works with custom rafter spacing' do
        calculator = described_class.new(
          panels: [panel],
          rafter_spacing: 20,
          first_rafter_x: 0
        )

        mounts = calculator.calculate

        mounts.each do |mount|
          expect(mount.x % 20).to be_within(0.01).of(0)
        end
      end
    end
  end
end
