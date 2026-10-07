require 'spec_helper'
require 'tempfile'
require 'fileutils'
require 'tmpdir'

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

          # Create main file that requires helper (the file's directory is
          # added to the load path by the compiler)
          main_source = "require 'helper'\nputs Helper"
          main_path = File.join(dir, 'main.rb')

          result = compiler.compile(main_source, main_path)

          # Dependencies list every processed file: required files by their
          # load-path-relative name and the entry by the path it was given.
          # The Vite plugin resolves both forms (resolveDependencyPath).
          expect(result[:dependencies]).to include(main_path)
          expect(result[:dependencies]).to include(a_string_ending_with('helper.rb'))
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
        # Only the entry itself
        expect(result[:dependencies]).to eq(['empty.rb'])
      end
    end
  end

  describe 'external_runtime option' do
    let(:source) { "require 'opal'\nrequire 'set'\nputs 'app'" }

    it 'bundles corelib by default' do
      result = described_class.new.compile(source, 'app.rb')

      expect(result[:code]).to include('Opal.modules["corelib/kernel"]')
    end

    it 'leaves corelib out of the output when enabled' do
      result = described_class.new(external_runtime: true).compile(source, 'app.rb')

      expect(result[:code]).not_to include('Opal.modules["corelib/kernel"]')
      expect(result[:code]).not_to include('Opal already loaded')
      expect(result[:code]).to include('$puts("app")')
    end
  end

  describe '.runtime_requires' do
    it 'lists opal and the corelib files bundled in runtime_code' do
      expect(described_class.runtime_requires).to include('opal', 'corelib/runtime', 'corelib/kernel')
    end
  end

  describe '.runtime_code' do
    it 'returns Opal runtime code' do
      runtime = described_class.runtime_code

      expect(runtime).to be_a(String)
      expect(runtime).to include('Opal')
      expect(runtime.length).to be > 0
    end

    it 'marks opal itself as loaded so bundles can require it' do
      expect(described_class.runtime_code).to include('Opal.loaded(["opal"])')
    end
  end

  describe 'built-in concerns' do
    node_available = system('node --version', out: File::NULL, err: File::NULL)

    opal_dir = File.expand_path('../opal', __dir__)

    Dir[File.join(opal_dir, 'opal_vite', 'concerns', '**', '*.rb')].sort.each do |path|
      name = path.delete_prefix("#{opal_dir}/").delete_suffix('.rb')

      it "compiles #{name} to syntactically valid JavaScript" do
        skip 'node is not installed' unless node_available

        result = described_class.new.compile("require '#{name}'", 'entry.rb')
        Tempfile.create(['concern', '.js']) do |file|
          file.write(result[:code])
          file.flush
          output = `node --check #{file.path} 2>&1`
          expect($?.success?).to be(true), output
        end
      end
    end
  end

  describe 'include_concerns option' do
    let(:source) { "require 'opal_vite/concerns/v1/base64_helpers'" }

    it 'makes the built-in concerns requirable by default' do
      expect { described_class.new.compile(source, 'entry.rb') }.not_to raise_error
    end

    it 'leaves the built-in concerns out of the load path when disabled' do
      # MissingRequire is a LoadError, so #compile's `rescue StandardError`
      # does not wrap it in CompilationError.
      expect { described_class.new(include_concerns: false).compile(source, 'entry.rb') }
        .to raise_error(Opal::Builder::MissingRequire, %r{opal_vite/concerns/v1/base64_helpers})
    end
  end

  describe 'load_paths option' do
    it 'resolves requires from the given directories' do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, 'lib'))
        FileUtils.mkdir_p(File.join(dir, 'app'))
        File.write(File.join(dir, 'lib', 'shared_util.rb'), "SHARED_UTIL = 'from-load-path'")
        entry = File.join(dir, 'app', 'main.rb')

        expect { described_class.new.compile("require 'shared_util'", entry) }
          .to raise_error(Opal::Builder::MissingRequire)

        result = described_class.new(load_paths: [File.join(dir, 'lib')]).compile("require 'shared_util'", entry)
        expect(result[:code]).to include('from-load-path')
      end
    end
  end

  describe 'compiler_options option' do
    it "passes them to Opal's compiler" do
      source = "def one(a); a; end"
      default = described_class.new.compile(source, 'entry.rb')[:code]
      checked = described_class.new(compiler_options: { arity_check: true }).compile(source, 'entry.rb')[:code]

      expect(checked).not_to eq(default)
      expect(checked).to include('$$parameters').or include('Opal.ac(')
    end
  end
end
