require 'optparse'
require 'opal/vite'

module Opal
  module Vite
    class CLI
      def initialize(argv)
        @argv = argv
        @options = {}
      end

      def run
        command = @argv.shift

        case command
        when 'compile'
          compile_command
        when 'version', '-v', '--version'
          version_command
        when 'help', '-h', '--help', nil
          help_command
        else
          puts "Unknown command: #{command}"
          puts "Run 'opal-vite help' for usage information"
          exit 1
        end
      end

      private

      def compile_command
        # Parse options first so they may appear before or after the file name
        parse_compile_options
        file_path = @argv.shift

        unless file_path
          puts "Error: No file specified"
          puts "Usage: opal-vite compile FILE"
          exit 1
        end

        unless File.exist?(file_path)
          puts "Error: File not found: #{file_path}"
          exit 1
        end

        # Without -o the compiled JS goes to stdout, so progress messages go to
        # stderr to keep stdout a clean JS stream
        log = @options[:output] ? $stdout : $stderr

        begin
          log.puts "Compiling #{file_path}..."

          config = Opal::Vite::Config.new
          config.source_map_enabled = !!@options[:source_map]
          compiler = Opal::Vite::Compiler.new(config: config)
          source = File.read(file_path)
          result = compiler.compile(source, file_path)

          if @options[:output]
            output_file = @options[:output]
            File.write(output_file, result[:code])
            puts "✅ Compiled to: #{output_file}"

            if @options[:source_map] && result[:map]
              map_file = "#{output_file}.map"
              File.write(map_file, result[:map])
              puts "✅ Source map: #{map_file}"
            end
          else
            puts result[:code]
          end

          if @options[:verbose]
            log.puts "\nDependencies:"
            result[:dependencies].each do |dep|
              log.puts "  - #{dep}"
            end
          end

          log.puts "✅ Compilation successful!"
        rescue => e
          puts "❌ Compilation failed: #{e.message}"
          puts e.backtrace.first(5).join("\n") if @options[:verbose]
          exit 1
        end
      end

      def version_command
        puts "opal-vite version #{Opal::Vite::VERSION}"
        puts "opal version #{Opal::VERSION}"
      end

      def help_command
        puts <<~HELP
          opal-vite - Integrate Opal with Vite

          USAGE:
            opal-vite COMMAND [OPTIONS]

          COMMANDS:
            compile FILE    Compile a Ruby file to JavaScript
            version         Show version information
            help            Show this help message

          COMPILE OPTIONS:
            -o, --output FILE       Write output to FILE
            -m, --source-map        Generate source map
            -v, --verbose           Show verbose output

          EXAMPLES:
            # Compile a file and print to stdout
            opal-vite compile app.rb

            # Compile and save to a file
            opal-vite compile app.rb -o app.js

            # Compile with source map
            opal-vite compile app.rb -o app.js -m

            # Show version
            opal-vite version

          For more information, visit: https://github.com/opal/opal-vite
        HELP
      end

      def parse_compile_options
        OptionParser.new do |opts|
          opts.on('-o', '--output FILE', 'Output file') do |file|
            @options[:output] = file
          end

          opts.on('-m', '--source-map', 'Generate source map') do
            @options[:source_map] = true
          end

          opts.on('-v', '--verbose', 'Verbose output') do
            @options[:verbose] = true
          end
        end.parse!(@argv)
      rescue OptionParser::ParseError => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
