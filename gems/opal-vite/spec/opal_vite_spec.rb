require 'spec_helper'

RSpec.describe Opal::Vite do
  describe '.opal_lib_path' do
    it "points at the gem's opal/ directory" do
      expected = File.expand_path('../opal', __dir__)

      expect(described_class.opal_lib_path).to eq(expected)
      expect(File.directory?(File.join(described_class.opal_lib_path, 'opal_vite', 'concerns'))).to be true
    end
  end
end
