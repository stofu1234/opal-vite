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
        # This file is lib/opal-vite.rb, so opal/ is one level up
        File.expand_path('../opal', __dir__)
      end

      # CLI entry point for compilation
      # @param file_path [String] The path to the Ruby file to compile
      # @param include_concerns [Boolean] Whether to include built-in concerns
      # @param source_map [Boolean] Whether to generate source maps
      # @param stubs [Array<String>] List of modules to stub (return empty implementations)
      # @param external_runtime [Boolean] Leave Opal's corelib out of the output
      #   (the caller loads it separately, e.g. via the `/@opal-runtime` module)
      # @param load_paths [Array<String>] Extra directories searched by `require`
      # @param arity_check [Boolean, nil] Opal's arity_check compiler option (nil: Opal's default)
      # @param freezing [Boolean, nil] Opal's freezing compiler option (nil: Opal's default)
      def compile_for_vite(file_path, include_concerns: true, source_map: true, stubs: [], external_runtime: false,
                           load_paths: [], arity_check: nil, freezing: nil)
        # Temporarily override source map setting if specified
        original_source_map = config.source_map_enabled
        config.source_map_enabled = source_map

        compiler = Compiler.new(
          include_concerns: include_concerns,
          stubs: stubs,
          external_runtime: external_runtime,
          load_paths: load_paths,
          compiler_options: { arity_check: arity_check, freezing: freezing }.compact
        )
        result = compiler.compile_file(file_path)

        # Output JSON to stdout for the Vite plugin to consume
        puts JSON.generate(result)
      rescue Compiler::CompilationError => e
        STDERR.puts e.message
        exit 1
      ensure
        config.source_map_enabled = original_source_map
      end
    end
  end
end
