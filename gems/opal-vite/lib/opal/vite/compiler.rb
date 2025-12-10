require 'opal'
require 'json'

module Opal
  module Vite
    class Compiler
      class CompilationError < StandardError; end

      def initialize(options = {})
        @options = options
        @config = options[:config] || Opal::Vite.config
      end

      # Compile Ruby source code to JavaScript
      # Returns a hash with :code, :map, and :dependencies
      def compile(source, file_path)
        begin
          # Use Opal::Builder and add the file's directory to load paths
          builder = Opal::Builder.new

          # Add the directory containing the file to load paths
          # This allows require statements to work relative to the file
          file_dir = File.dirname(File.expand_path(file_path))
          builder.append_paths(file_dir)

          # Also add parent directories for common patterns like 'lib/foo'
          parent_dir = File.dirname(file_dir)
          builder.append_paths(parent_dir)

          builder.build_str(source, file_path)

          result = {
            code: builder.to_s,
            dependencies: extract_dependencies(builder)
          }

          # Try to extract source map if available
          if @config.source_map_enabled
            begin
              # Opal::Builder should have source map information
              # Try to get it from the processed assets
              source_map = extract_source_map(builder)
              result[:map] = source_map if source_map
            rescue => e
              # Source map extraction failed, log but don't fail compilation
              warn "Warning: Failed to extract source map for #{file_path}: #{e.message}" if ENV['DEBUG']
            end
          end

          result
        rescue StandardError => e
          raise CompilationError, "Failed to compile #{file_path}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
        end
      end

      # Compile a Ruby file to JavaScript
      def compile_file(file_path)
        unless File.exist?(file_path)
          raise CompilationError, "File not found: #{file_path}"
        end

        source = File.read(file_path)
        compile(source, file_path)
      end

      # Get the Opal runtime code
      def self.runtime_code
        builder = Opal::Builder.new
        builder.build('opal')
        builder.to_s
      end

      private

      def compiler_options
        @config.to_compiler_options
      end

      def extract_dependencies(builder)
        # Extract required files from the builder
        builder.processed.map { |asset| asset.filename }.compact
      end

      def extract_source_map(builder)
        # Get source map from the builder's processed assets
        # Opal stores source maps in the compiled assets
        return nil unless builder.processed.any?

        # Get the main compiled asset (usually the last one)
        main_asset = builder.processed.last
        return nil unless main_asset

        # Check if the asset has source map data
        if main_asset.respond_to?(:source_map) && main_asset.source_map
          return main_asset.source_map.to_json
        end

        # Try to get from the builder directly
        if builder.respond_to?(:source_map) && builder.source_map
          return builder.source_map.to_json
        end

        nil
      end
    end
  end
end
