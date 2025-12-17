require 'opal'
require 'json'
require 'pathname'

module Opal
  module Vite
    class Compiler
      class CompilationError < StandardError; end

      def initialize(options = {})
        @options = options
        @config = options[:config] || Opal::Vite.config
        @include_concerns = options.fetch(:include_concerns, true)
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

          # Add gem paths from $LOAD_PATH so Opal can find gems
          add_gem_paths(builder)

          builder.build_str(source, file_path)

          result = {
            code: builder.to_s,
            dependencies: extract_dependencies(builder)
          }

          # Extract source map if enabled
          if @config.source_map_enabled
            begin
              source_map = extract_source_map(builder, file_path)
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

      def add_gem_paths(builder)
        # Add gem directories from $LOAD_PATH to Opal's load paths
        # This allows Opal to find and compile gems like inesita

        # Add opal-vite's built-in concerns if enabled
        if @include_concerns
          opal_vite_opal_path = Opal::Vite.opal_lib_path
          if File.directory?(opal_vite_opal_path)
            builder.append_paths(opal_vite_opal_path) unless builder.path_reader.paths.include?(opal_vite_opal_path)
          end
        end

        # First collect all gem paths
        gem_lib_paths = []
        gem_opal_paths = []

        $LOAD_PATH.each do |path|
          # Only process gem directories
          if path.include?('/gems/') && File.directory?(path)
            gem_lib_paths << path

            # Check if gem has an opal directory (for gems like inesita)
            # Gems with opal-specific code often have an 'opal' directory sibling to 'lib'
            gem_root = File.dirname(path)
            opal_path = File.join(gem_root, 'opal')
            if File.directory?(opal_path)
              gem_opal_paths << opal_path
            end
          end
        end

        # Add opal directories FIRST so they take priority over lib directories
        # This ensures that 'require "inesita"' finds opal/inesita.rb before lib/inesita.rb
        gem_opal_paths.uniq.each do |path|
          builder.append_paths(path) unless builder.path_reader.paths.include?(path)
        end

        # Then add regular lib directories, but ONLY for Opal-compatible gems
        # to avoid pulling in Rails/server-side dependencies
        gem_lib_paths.uniq.each do |path|
          # Only add paths from gems that:
          # 1. Have an 'opal' directory (already processed above)
          # 2. OR have 'opal' in their gem name
          gem_root = File.dirname(path)
          gem_name = File.basename(gem_root)

          # Check if this gem has opal support
          is_opal_gem = gem_name.start_with?('opal') ||
                       gem_opal_paths.any? { |opal_path| opal_path.start_with?(gem_root) }

          if is_opal_gem
            builder.append_paths(path) unless builder.path_reader.paths.include?(path)
          end
        end
      end

      def compiler_options
        @config.to_compiler_options
      end

      def extract_dependencies(builder)
        # Extract required files from the builder
        builder.processed.map { |asset| asset.filename }.compact
      end

      def extract_source_map(builder, file_path)
        # Use Builder's source_map method which returns an Opal::SourceMap::Index
        # This combines all processed source maps into a single index
        return nil unless builder.respond_to?(:source_map)

        source_map = builder.source_map
        return nil unless source_map

        # Convert to hash
        map_hash = source_map.to_h
        return nil unless map_hash

        # Vite doesn't support index source maps with 'sections' array
        # Convert to standard format for browser compatibility
        if map_hash['sections']
          map_hash = convert_index_to_standard_sourcemap(map_hash, file_path)
        elsif map_hash['sources']
          # Standard source map format - just normalize paths
          map_hash['sources'] = map_hash['sources'].map do |source|
            normalize_source_path(source, file_path)
          end
        end

        return nil unless map_hash

        map_hash.to_json
      end

      def convert_index_to_standard_sourcemap(index_map, file_path)
        sections = index_map['sections']
        return nil if sections.nil? || sections.empty?

        # For single section, extract and return that section's map
        if sections.length == 1
          section_map = sections.first['map']
          return nil unless section_map

          # Normalize source paths
          if section_map['sources']
            section_map['sources'] = section_map['sources'].map do |source|
              normalize_source_path(source, file_path)
            end
          end

          return section_map
        end

        # For multiple sections, merge them into a single standard source map
        # This is more complex - we need to combine sources, sourcesContent, and adjust mappings
        merged = {
          'version' => 3,
          'sources' => [],
          'sourcesContent' => [],
          'names' => [],
          'mappings' => ''
        }

        sections.each_with_index do |section, idx|
          section_map = section['map']
          next unless section_map

          offset = section['offset'] || { 'line' => 0, 'column' => 0 }
          offset_lines = offset['line'] || 0

          # Add sources and sourcesContent
          source_offset = merged['sources'].length
          if section_map['sources']
            section_map['sources'].each_with_index do |source, i|
              merged['sources'] << normalize_source_path(source, file_path)
              if section_map['sourcesContent'] && section_map['sourcesContent'][i]
                merged['sourcesContent'] << section_map['sourcesContent'][i]
              else
                merged['sourcesContent'] << nil
              end
            end
          end

          # Add names
          name_offset = merged['names'].length
          if section_map['names']
            merged['names'].concat(section_map['names'])
          end

          # Add mappings with proper offset
          if section_map['mappings']
            # Add newlines for offset if needed
            if idx > 0 && offset_lines > 0
              merged['mappings'] += ';' * offset_lines
            elsif idx > 0
              merged['mappings'] += ';'
            end

            # Append the section's mappings
            # Note: In a proper implementation, we'd need to re-encode with adjusted offsets
            # For now, just append the raw mappings
            merged['mappings'] += section_map['mappings']
          end
        end

        merged
      end

      def normalize_source_path(source, file_path)
        # Convert absolute paths to relative for better browser debugging
        return source if source.nil? || source.empty?

        # If source is already relative or a URL, keep it
        return source unless source.start_with?('/')

        # Try to make path relative to the original file
        begin
          Pathname.new(source).relative_path_from(Pathname.new(File.dirname(file_path))).to_s
        rescue ArgumentError
          # On different drives/mounts, keep absolute path
          source
        end
      end
    end
  end
end
