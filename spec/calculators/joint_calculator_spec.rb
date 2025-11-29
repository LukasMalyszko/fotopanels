# frozen_string_literal: true

require_relative '../../lib/calculators/joint_calculator'
require_relative '../../lib/models/panel'

RSpec.describe Calculators::JointCalculator do
  describe '#calculate' do
    context 'with horizontally adjacent panels' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 0, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'creates joints between adjacent panels' do
        joints = calculator.calculate

        expect(joints).not_to be_empty
      end

      it 'places joint at panel corner' do
        joints = calculator.calculate

        # Joint should be at the corner where panels meet
        joint = joints.first
        expect(joint.x).to be_within(0.5).of(panels[0].right_edge)
        expect(joint.x).to be_within(0.5).of(panels[1].x)
      end
    end

    context 'with vertically adjacent panels' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 0, y: 71.6, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 71.6, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'creates joints between vertically stacked panels' do
        joints = calculator.calculate

        expect(joints).not_to be_empty
      end

      it 'places joint at panel corner vertically' do
        joints = calculator.calculate

        # Should have a joint where the vertical gap meets horizontal gap (interior corner)
        vertical_joint = joints.find { |j| j.y > 70 && j.y < 73 }
        expect(vertical_joint).not_to be_nil
        expect(vertical_joint.y).to be_within(1.0).of(71.1)
      end
    end

    context 'with grid layout (4-panel corner)' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 0, y: 71.6, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 71.6, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'creates corner joint where 4 panels meet' do
        joints = calculator.calculate

        # Should have joints for horizontal, vertical, and corner connections
        expect(joints.size).to be >= 1
      end

      it 'creates unique joints only' do
        joints = calculator.calculate

        expect(joints.uniq.size).to eq(joints.size)
      end
    end

    context 'with non-adjacent panels' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 100, y: 100, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'does not create joints between distant panels' do
        joints = calculator.calculate

        expect(joints).to be_empty
      end
    end

    context 'with the example dataset' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 45.05, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 90.1, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 0, y: 71.6, width: 44.7, height: 71.1),
          Models::Panel.new(x: 135.15, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 135.15, y: 71.6, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'creates multiple joints for complex layout' do
        joints = calculator.calculate

        expect(joints.size).to be >= 4
      end
    end
  end
end
