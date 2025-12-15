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

      # CLI entry point for compilation
      # @param file_path [String] Path to the Ruby file to compile
      # @param include_concerns [Boolean] Whether to include built-in concerns in load path
      def compile_for_vite(file_path, include_concerns: true)
        compiler = Compiler.new(include_concerns: include_concerns)
        result = compiler.compile_file(file_path)

        # Output JSON to stdout for the Vite plugin to consume
        puts JSON.generate(result)
      rescue Compiler::CompilationError => e
        STDERR.puts e.message
        exit 1
      end

      # Returns the path to the gem's opal directory containing built-in concerns
      def opal_lib_path
        File.expand_path('../../opal', __dir__)
      end
    end
  end
end
