require 'spec_helper'
require 'tempfile'
require 'fileutils'

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

    context 'with require_tree' do
      # Regression guard: Opal::Builder expands `require_tree` at compile time,
      # so opal-vite supports Sprockets-style directory bundling out of the box.
      # See docs/MIGRATION.md (Scenario 4) and issue #54.
      it 'bundles every .rb file under the directory, including nested ones' do
        Dir.mktmpdir do |dir|
          FileUtils.mkdir_p(File.join(dir, 'controllers', 'nested'))
          File.write(File.join(dir, 'controllers', 'alpha.rb'), 'puts "ALPHA_LOADED"')
          File.write(File.join(dir, 'controllers', 'nested', 'beta.rb'), 'puts "BETA_LOADED"')

          main_source = "require_tree './controllers'\nputs 'MAIN_LOADED'"
          result = compiler.compile(main_source, File.join(dir, 'main.rb'))

          expect(result[:code]).to include('ALPHA_LOADED')
          expect(result[:code]).to include('BETA_LOADED')
          expect(result[:code]).to include('MAIN_LOADED')
        end
      end
    end

    context 'with the OpalComponent base class' do
      # Issue #55: framework-agnostic lightweight component base class.
      it 'compiles a component that subclasses OpalComponent' do
        source = <<~'RUBY'
          require 'opal_vite/concerns/v1/component'

          class Counter < OpalComponent
            def initial_state
              { count: 0 }
            end

            def render
              "<button>count: #{state[:count]}</button>"
            end

            def after_render
              on('button', 'click') { set_state(count: state[:count] + 1) }
            end
          end
        RUBY

        result = compiler.compile(source, 'counter_component.rb')

        expect(result[:code]).to be_a(String)
        expect(result[:code]).to include('Counter')
        # The base class (pulled in via require) defines set_state/mount.
        expect(result[:code]).to include('set_state')
        expect(result[:code]).to include('mount')
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
