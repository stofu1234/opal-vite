require 'spec_helper'
require 'tempfile'

RSpec.describe Opal::Vite::Config do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.source_map_enabled).to be true
      expect(config.arity_check).to be false
      expect(config.freezing).to be true
      expect(config.esm).to be true
      expect(config.dynamic_require_severity).to eq(:ignore)
      expect(config.missing_require_severity).to eq(:error)
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

  describe '#apply_hash' do
    it 'sets known options and ignores unknown keys' do
      config.apply_hash('arity_check' => true, 'freezing' => false, 'no_such_option' => 1)

      expect(config.arity_check).to be true
      expect(config.freezing).to be false
      expect(config).not_to respond_to(:no_such_option)
    end
  end

  describe '.load_from_file' do
    it 'applies options from a JSON file' do
      Tempfile.create(['opal-vite', '.json']) do |file|
        file.write('{"source_map_enabled": false, "esm": false}')
        file.flush

        loaded = described_class.load_from_file(file.path)

        expect(loaded.source_map_enabled).to be false
        expect(loaded.esm).to be false
        expect(loaded.freezing).to be true
      end
    end

    it 'returns defaults when the file does not exist' do
      loaded = described_class.load_from_file('/nonexistent/opal-vite.json')

      expect(loaded.source_map_enabled).to be true
    end
  end

  describe '#to_compiler_options' do
    it 'returns the options as a hash' do
      config.source_map_enabled = false
      config.arity_check = true

      expect(config.to_compiler_options).to eq(
        source_map_enabled: false,
        arity_check: true,
        freezing: true,
        esm: true,
        dynamic_require_severity: :ignore,
        missing_require_severity: :error
      )
    end
  end
end
