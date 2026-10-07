require 'spec_helper'
require 'json'
require 'stringio'
require 'tmpdir'
require 'fileutils'

RSpec.describe Opal::Vite do
  describe '.opal_lib_path' do
    it "points at the gem's opal/ directory" do
      expected = File.expand_path('../opal', __dir__)

      expect(described_class.opal_lib_path).to eq(expected)
      expect(File.directory?(File.join(described_class.opal_lib_path, 'opal_vite', 'concerns'))).to be true
    end
  end

  describe '.compile_for_vite' do
    it 'accepts load_paths and compiler options, and restores the source map setting' do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, 'lib'))
        File.write(File.join(dir, 'lib', 'shared_util.rb'), "SHARED_UTIL = 'from-load-path'")
        entry = File.join(dir, 'main.rb')
        File.write(entry, "require 'shared_util'")

        original = described_class.config.source_map_enabled
        output = capture_stdout do
          described_class.compile_for_vite(entry, source_map: !original, load_paths: [File.join(dir, 'lib')],
                                                  arity_check: true, freezing: false)
        end

        expect(JSON.parse(output)['code']).to include('from-load-path')
        expect(described_class.config.source_map_enabled).to eq(original)
      end
    end
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end
end
