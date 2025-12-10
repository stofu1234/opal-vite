require 'spec_helper'
require 'tempfile'

RSpec.describe Opal::Vite::Compiler do
  let(:compiler) { described_class.new }

  describe '#compile' do
    context 'with simple Ruby code' do
      it 'compiles successfully' do
        source = 'puts "Hello, World!"'
        result = compiler.compile(source, 'test.rb')

        expect(result).to be_a(Hash)
        expect(result[:code]).to be_a(String)
        expect(result[:code]).to include('Hello, World!')
        expect(result[:dependencies]).to be_an(Array)
      end
    end

    context 'with Ruby classes' do
      it 'compiles class definitions' do
        source = <<~RUBY
          class Calculator
            def add(a, b)
              a + b
            end
          end

          calc = Calculator.new
          puts calc.add(2, 3)
        RUBY

        result = compiler.compile(source, 'calculator.rb')

        expect(result[:code]).to include('Calculator')
        expect(result[:code]).to include('add')
      end
    end

    context 'with require statements' do
      it 'tracks dependencies' do
        Dir.mktmpdir do |dir|
          # Create helper file
          helper_path = File.join(dir, 'helper.rb')
          File.write(helper_path, 'class Helper; end')

          # Create main file that requires helper
          main_source = "require 'helper'\nputs Helper"

          # Configure load paths
          builder = Opal::Builder.new
          builder.append_paths(dir)

          result = compiler.compile(main_source, File.join(dir, 'main.rb'))

          expect(result[:dependencies]).to include('helper')
        end
      end
    end

    context 'with invalid syntax' do
      it 'raises an error' do
        source = 'def invalid syntax'

        expect {
          compiler.compile(source, 'invalid.rb')
        }.to raise_error
      end
    end

    context 'with empty source' do
      it 'compiles successfully' do
        source = ''
        result = compiler.compile(source, 'empty.rb')

        expect(result[:code]).to be_a(String)
        expect(result[:dependencies]).to be_empty
      end
    end
  end

  describe '.runtime_code' do
    it 'returns Opal runtime code' do
      runtime = described_class.runtime_code

      expect(runtime).to be_a(String)
      expect(runtime).to include('Opal')
      expect(runtime.length).to be > 0
    end
  end
end
