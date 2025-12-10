require 'spec_helper'

RSpec.describe Opal::Vite::Config do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.load_paths).to eq([])
      expect(config.source_map_enabled).to be true
      expect(config.debug).to be false
    end
  end

  describe '#load_paths' do
    it 'can be set' do
      config.load_paths = ['/path/to/lib']
      expect(config.load_paths).to eq(['/path/to/lib'])
    end

    it 'accepts multiple paths' do
      paths = ['/path/one', '/path/two']
      config.load_paths = paths
      expect(config.load_paths).to eq(paths)
    end
  end

  describe '#source_map_enabled' do
    it 'can be set to false' do
      config.source_map_enabled = false
      expect(config.source_map_enabled).to be false
    end

    it 'can be set to true' do
      config.source_map_enabled = true
      expect(config.source_map_enabled).to be true
    end
  end

  describe '#debug' do
    it 'can be enabled' do
      config.debug = true
      expect(config.debug).to be true
    end

    it 'can be disabled' do
      config.debug = false
      expect(config.debug).to be false
    end
  end

  describe '#to_h' do
    it 'returns configuration as hash' do
      config.load_paths = ['/test']
      config.source_map_enabled = false
      config.debug = true

      hash = config.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:load_paths]).to eq(['/test'])
      expect(hash[:source_map_enabled]).to be false
      expect(hash[:debug]).to be true
    end
  end
end
