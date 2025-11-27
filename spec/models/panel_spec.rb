# frozen_string_literal: true

require_relative '../../lib/models/panel'

RSpec.describe Models::Panel do
  let(:panel) { described_class.new(x: 0, y: 0, width: 44.7, height: 71.1) }

  describe '#initialize' do
    it 'sets position and dimensions' do
      expect(panel.x).to eq(0.0)
      expect(panel.y).to eq(0.0)
      expect(panel.width).to eq(44.7)
      expect(panel.height).to eq(71.1)
    end

    it 'converts values to floats' do
      panel = described_class.new(x: 10, y: 20, width: 30, height: 40)
      expect(panel.x).to be_a(Float)
      expect(panel.y).to be_a(Float)
    end
  end

  describe '#right_edge' do
    it 'calculates the right edge correctly' do
      expect(panel.right_edge).to eq(44.7)
    end
  end

  describe '#bottom_edge' do
    it 'calculates the bottom edge correctly' do
      expect(panel.bottom_edge).to eq(71.1)
    end
  end

  describe '#horizontally_adjacent?' do
    it 'returns true for adjacent panels with small gap' do
      panel2 = described_class.new(x: 45.05, y: 0, width: 44.7, height: 71.1)
      expect(panel.horizontally_adjacent?(panel2)).to be true
    end

    it 'returns false for panels with large gap' do
      panel2 = described_class.new(x: 50, y: 0, width: 44.7, height: 71.1)
      expect(panel.horizontally_adjacent?(panel2)).to be false
    end

    it 'returns false for panels not vertically aligned' do
      panel2 = described_class.new(x: 45.05, y: 100, width: 44.7, height: 71.1)
      expect(panel.horizontally_adjacent?(panel2)).to be false
    end
  end

  describe '#vertically_adjacent?' do
    it 'returns true for vertically stacked panels with small gap' do
      panel2 = described_class.new(x: 0, y: 71.6, width: 44.7, height: 71.1)
      expect(panel.vertically_adjacent?(panel2)).to be true
    end

    it 'returns false for panels with large vertical gap' do
      panel2 = described_class.new(x: 0, y: 80, width: 44.7, height: 71.1)
      expect(panel.vertically_adjacent?(panel2)).to be false
    end

    it 'returns false for panels not horizontally aligned' do
      panel2 = described_class.new(x: 100, y: 71.6, width: 44.7, height: 71.1)
      expect(panel.vertically_adjacent?(panel2)).to be false
    end
  end

  describe '#overlaps_vertically?' do
    it 'returns true for panels with overlapping Y ranges' do
      panel2 = described_class.new(x: 50, y: 30, width: 44.7, height: 71.1)
      expect(panel.overlaps_vertically?(panel2)).to be true
    end

    it 'returns false for panels with non-overlapping Y ranges' do
      panel2 = described_class.new(x: 50, y: 100, width: 44.7, height: 71.1)
      expect(panel.overlaps_vertically?(panel2)).to be false
    end
  end

  describe '#overlaps_horizontally?' do
    it 'returns true for panels with overlapping X ranges' do
      panel2 = described_class.new(x: 20, y: 100, width: 44.7, height: 71.1)
      expect(panel.overlaps_horizontally?(panel2)).to be true
    end

    it 'returns false for panels with non-overlapping X ranges' do
      panel2 = described_class.new(x: 100, y: 0, width: 44.7, height: 71.1)
      expect(panel.overlaps_horizontally?(panel2)).to be false
    end
  end
end
