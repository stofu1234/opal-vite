require 'opal'
require 'json'

require_relative 'opal/vite/version'
require_relative 'opal/vite/config'
require_relative 'opal/vite/compiler'
require_relative 'opal/vite/source_map'

module Opal
  module Vite
    class Error < StandardError; end

    class << self
      attr_writer :config

      def config
        @config ||= Config.new
      end

      def configure
        yield(config) if block_given?
      end

      # Returns the path to the opal/ directory in this gem
      # Contains built-in concerns like StimulusHelpers
      def opal_lib_path
        File.expand_path('../../opal', __dir__)
      end

      # CLI entry point for compilation
      # @param file_path [String] The path to the Ruby file to compile
      # @param include_concerns [Boolean] Whether to include built-in concerns
      # @param source_map [Boolean] Whether to generate source maps
      def compile_for_vite(file_path, include_concerns: true, source_map: true)
        # Temporarily override source map setting if specified
        original_source_map = config.source_map_enabled
        config.source_map_enabled = source_map

        compiler = Compiler.new(include_concerns: include_concerns)
        result = compiler.compile_file(file_path)

        # Output JSON to stdout for the Vite plugin to consume
        puts JSON.generate(result)

        # Restore original setting
        config.source_map_enabled = original_source_map
      rescue Compiler::CompilationError => e
        STDERR.puts e.message
        exit 1
      end
    end
  end
end
