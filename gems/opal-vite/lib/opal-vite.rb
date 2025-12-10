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
      def compile_for_vite(file_path)
        compiler = Compiler.new
        result = compiler.compile_file(file_path)

        # Output JSON to stdout for the Vite plugin to consume
        puts JSON.generate(result)
      rescue Compiler::CompilationError => e
        STDERR.puts e.message
        exit 1
      end
    end
  end
end
