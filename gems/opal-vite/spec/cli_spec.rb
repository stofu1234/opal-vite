require 'spec_helper'
require 'opal/vite/cli'
require 'tempfile'
require 'tmpdir'
require 'stringio'

RSpec.describe Opal::Vite::CLI do
  describe '#run' do
    context 'with compile command' do
      it 'compiles a Ruby file' do
        Tempfile.create(['test', '.rb']) do |file|
          file.write('puts "test"')
          file.flush

          cli = described_class.new(['compile', file.path])

          expect {
            cli.run
          }.to output(/Compiling/).to_stderr
        end
      end

      it 'shows error for missing file' do
        cli = described_class.new(['compile'])

        expect {
          cli.run
        }.to output(/No file specified/).to_stdout
         .and raise_error(SystemExit)
      end

      it 'shows error for non-existent file' do
        cli = described_class.new(['compile', '/nonexistent.rb'])

        expect {
          cli.run
        }.to output(/File not found/).to_stdout
         .and raise_error(SystemExit)
      end
    end

    context 'with version command' do
      it 'shows version information' do
        cli = described_class.new(['version'])

        expect {
          cli.run
        }.to output(/opal-vite version/).to_stdout
      end

      it 'accepts -v flag' do
        cli = described_class.new(['-v'])

        expect {
          cli.run
        }.to output(/opal-vite version/).to_stdout
      end

      it 'accepts --version flag' do
        cli = described_class.new(['--version'])

        expect {
          cli.run
        }.to output(/opal-vite version/).to_stdout
      end
    end

    context 'with help command' do
      it 'shows help message' do
        cli = described_class.new(['help'])

        expect {
          cli.run
        }.to output(/USAGE/).to_stdout
      end

      it 'accepts -h flag' do
        cli = described_class.new(['-h'])

        expect {
          cli.run
        }.to output(/USAGE/).to_stdout
      end

      it 'accepts --help flag' do
        cli = described_class.new(['--help'])

        expect {
          cli.run
        }.to output(/USAGE/).to_stdout
      end

      it 'shows help when no command given' do
        cli = described_class.new([])

        expect {
          cli.run
        }.to output(/USAGE/).to_stdout
      end
    end

    context 'with unknown command' do
      it 'shows error message' do
        cli = described_class.new(['unknown'])

        expect {
          cli.run
        }.to output(/Unknown command/).to_stdout
         .and raise_error(SystemExit)
      end
    end

    context 'with compile options' do
      it 'accepts output option' do
        Tempfile.create(['test', '.rb']) do |source_file|
          source_file.write('puts "test"')
          source_file.flush

          Tempfile.create(['output', '.js']) do |output_file|
            cli = described_class.new(['compile', source_file.path, '-o', output_file.path])

            expect {
              cli.run
            }.to output(/Compiled to/).to_stdout

            expect(File.exist?(output_file.path)).to be true
          end
        end
      end

      it 'accepts verbose option' do
        Tempfile.create(['test', '.rb']) do |file|
          file.write('puts "test"')
          file.flush

          cli = described_class.new(['compile', file.path, '-v'])

          expect {
            cli.run
          }.to output(/Dependencies/).to_stderr
        end
      end
    end

    context 'with options before the file name' do
      it 'keeps stdout a clean JS stream and skips the source map unless -m is given' do
        Tempfile.create(['test', '.rb']) do |file|
          file.write('puts "test"')
          file.flush

          cli = described_class.new(['compile', '-v', file.path])
          stdout = nil
          expect { stdout = capture_stdout { cli.run } }.to output(/Compiling/).to_stderr

          expect(stdout).not_to include('Compiling')
          expect(stdout).not_to include('Compilation successful')
        end
      end

      it 'writes a source map only with -m' do
        Tempfile.create(['test', '.rb']) do |file|
          file.write("puts 1\nputs 2")
          file.flush
          Dir.mktmpdir do |dir|
            out = File.join(dir, 'out.js')
            expect { described_class.new(['compile', file.path, '-o', out]).run }.to output.to_stdout
            expect(File.exist?("#{out}.map")).to be false

            expect { described_class.new(['compile', '-m', '-o', out, file.path]).run }.to output.to_stdout
            expect(File.exist?("#{out}.map")).to be true
          end
        end
      end

      it 'reports unknown options' do
        expect { described_class.new(['compile', '--bogus', 'x.rb']).run }
          .to output(/invalid option/).to_stdout.and raise_error(SystemExit)
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
end
