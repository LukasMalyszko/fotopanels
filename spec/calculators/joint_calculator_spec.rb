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

      it 'places joint between the panels' do
        joints = calculator.calculate
        
        # Joint should be between the two panels
        joint = joints.first
        expect(joint.x).to be > panels[0].right_edge
        expect(joint.x).to be < panels[1].x
      end
    end

    context 'with vertically adjacent panels' do
      let(:panels) do
        [
          Models::Panel.new(x: 0, y: 0, width: 44.7, height: 71.1),
          Models::Panel.new(x: 0, y: 71.6, width: 44.7, height: 71.1)
        ]
      end
      let(:calculator) { described_class.new(panels: panels) }

      it 'creates joints between vertically stacked panels' do
        joints = calculator.calculate
        
        expect(joints).not_to be_empty
      end

      it 'places joint between the panels vertically' do
        joints = calculator.calculate
        
        # Joint should be between the two panels vertically
        joint = joints.first
        expect(joint.y).to be > panels[0].bottom_edge
        expect(joint.y).to be < panels[1].y
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
