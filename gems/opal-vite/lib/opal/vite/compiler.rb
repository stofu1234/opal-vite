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
        @stubs = options.fetch(:stubs, [])
      end

      # Compile Ruby source code to JavaScript
      # Returns a hash with :code, :map, and :dependencies
      def compile(source, file_path)
        begin
          # Use Opal::Builder and add the file's directory to load paths
          builder = Opal::Builder.new(stubs: @stubs)

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
        # Use builder's combined source_map which includes all compiled files
        # This allows debugging of all required files (controllers, services, etc.)
        return nil unless builder.respond_to?(:source_map) && builder.source_map

        source_map = builder.source_map
        map_hash = deep_stringify_keys(source_map.to_h)
        return nil unless map_hash

        # If it's an index format with sections, merge all sections
        if map_hash['sections']
          map_hash = merge_all_sections(map_hash, file_path)
        end

        return nil unless map_hash

        # Add sourceRoot for proper browser debugging
        # This helps DevTools organize source files in a logical tree
        map_hash['sourceRoot'] = ''

        # Normalize source paths for browser debugging
        # Prefix with /opal-sources/ so they appear in a dedicated folder in DevTools
        if map_hash['sources']
          map_hash['sources'] = map_hash['sources'].map do |source|
            normalize_source_path_for_devtools(source, file_path)
          end
        end

        map_hash.to_json
      end

      # Recursively convert all hash keys to strings
      def deep_stringify_keys(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(key, value), result|
            result[key.to_s] = deep_stringify_keys(value)
          end
        when Array
          obj.map { |item| deep_stringify_keys(item) }
        else
          obj
        end
      end

      def merge_all_sections(index_map, file_path)
        sections = index_map['sections']
        return nil if sections.nil? || sections.empty?

        # For single section, just return that section's map
        if sections.length == 1
          return sections.first['map']
        end

        # Merge all sections into a single standard source map
        # This allows debugging of all files (application.rb + all required files)
        merged = {
          'version' => 3,
          'file' => File.basename(file_path),
          'sources' => [],
          'sourcesContent' => [],
          'names' => [],
          'mappings' => ''
        }

        # Track cumulative state for VLQ relative encoding
        # These track the "previous" values across all sections
        prev_source = 0
        prev_orig_line = 0
        prev_orig_col = 0
        prev_name = 0

        current_line = 0

        sections.each_with_index do |section, idx|
          section_map = section['map']
          next unless section_map

          offset = section['offset'] || { 'line' => 0, 'column' => 0 }
          section_start_line = offset['line'] || 0

          # Add empty lines to reach the section's starting line
          lines_to_add = section_start_line - current_line
          if lines_to_add > 0
            merged['mappings'] += ';' * lines_to_add
            current_line = section_start_line
          end

          # Track source and name index offsets for this section
          source_offset = merged['sources'].length
          name_offset = merged['names'].length

          # Add sources and sourcesContent from this section
          if section_map['sources']
            section_map['sources'].each_with_index do |source, i|
              merged['sources'] << source
              if section_map['sourcesContent'] && section_map['sourcesContent'][i]
                merged['sourcesContent'] << section_map['sourcesContent'][i]
              else
                merged['sourcesContent'] << nil
              end
            end
          end

          # Add names from this section
          if section_map['names']
            merged['names'].concat(section_map['names'])
          end

          # Process mappings from this section with index adjustment
          if section_map['mappings'] && !section_map['mappings'].empty?
            adjusted_mappings, prev_source, prev_orig_line, prev_orig_col, prev_name =
              adjust_section_mappings(
                section_map['mappings'],
                source_offset,
                name_offset,
                prev_source,
                prev_orig_line,
                prev_orig_col,
                prev_name
              )

            if idx > 0 && !merged['mappings'].empty? && !merged['mappings'].end_with?(';')
              merged['mappings'] += ';'
            end
            merged['mappings'] += adjusted_mappings

            # Update current_line to the last line we wrote to
            # section_start_line + number of semicolons in this section's mappings
            current_line = section_start_line + section_map['mappings'].count(';')
          end
        end

        merged
      end

      # Adjust mappings from a section by adding offsets to source/name indices
      # VLQ mappings use relative deltas. When merging sections:
      # - First section: no adjustment, just track final absolute state
      # - Later sections: adjust first segment's source/name delta to bridge from previous section's end state
      #
      # Returns: [adjusted_mappings, new_prev_source, new_prev_orig_line, new_prev_orig_col, new_prev_name]
      def adjust_section_mappings(mappings, source_offset, name_offset, prev_source, prev_orig_line, prev_orig_col, prev_name)
        return ['', prev_source, prev_orig_line, prev_orig_col, prev_name] if mappings.nil? || mappings.empty?

        result_lines = []
        lines = mappings.split(';', -1)

        # Track absolute state within this section (section-local, starting from 0)
        section_abs_source = 0
        section_abs_orig_line = 0
        section_abs_orig_col = 0
        section_abs_name = 0

        first_segment_processed = false

        lines.each do |line|
          if line.empty?
            result_lines << ''
            next
          end

          result_segments = []
          segments = line.split(',')

          segments.each do |segment|
            values = decode_vlq(segment)
            next if values.empty?

            # values[0] = generated column delta (always present, relative within line)
            # values[1] = source index delta
            # values[2] = original line delta
            # values[3] = original column delta
            # values[4] = name index delta

            gen_col_delta = values[0]

            if values.length > 1
              # Update section-local absolute positions
              section_abs_source += values[1]
              section_abs_orig_line += values[2] if values.length > 2
              section_abs_orig_col += values[3] if values.length > 3
              section_abs_name += values[4] if values.length > 4

              # Calculate global absolute positions (with offset)
              global_abs_source = section_abs_source + source_offset
              global_abs_name = section_abs_name + name_offset

              if !first_segment_processed
                # First segment: calculate delta from previous section's end state to this segment's global position
                new_source_delta = global_abs_source - prev_source
                new_orig_line_delta = section_abs_orig_line - prev_orig_line
                new_orig_col_delta = section_abs_orig_col - prev_orig_col
                new_name_delta = global_abs_name - prev_name

                new_values = [gen_col_delta, new_source_delta, new_orig_line_delta, new_orig_col_delta]
                new_values << new_name_delta if values.length > 4

                first_segment_processed = true
              else
                # Subsequent segments: deltas are already correct (relative within section = relative within merged)
                new_values = values.dup
              end

              result_segments << encode_vlq(new_values)

              # Update tracking for next section
              prev_source = global_abs_source
              prev_orig_line = section_abs_orig_line
              prev_orig_col = section_abs_orig_col
              prev_name = global_abs_name if values.length > 4
            else
              # Only generated column, no source mapping
              result_segments << encode_vlq([gen_col_delta])
            end
          end

          result_lines << result_segments.join(',')
        end

        [result_lines.join(';'), prev_source, prev_orig_line, prev_orig_col, prev_name]
      end

      # VLQ Base64 character set
      VLQ_BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.freeze
      VLQ_BASE64_VALUES = VLQ_BASE64_CHARS.each_char.with_index.to_h.freeze
      VLQ_BASE_SHIFT = 5
      VLQ_BASE = 1 << VLQ_BASE_SHIFT  # 32
      VLQ_BASE_MASK = VLQ_BASE - 1     # 31
      VLQ_CONTINUATION_BIT = VLQ_BASE  # 32

      # Decode a VLQ-encoded segment into an array of integers
      def decode_vlq(segment)
        return [] if segment.nil? || segment.empty?

        values = []
        shift = 0
        value = 0

        segment.each_char do |char|
          digit = VLQ_BASE64_VALUES[char]
          return values if digit.nil?  # Invalid character

          continuation = (digit & VLQ_CONTINUATION_BIT) != 0
          digit &= VLQ_BASE_MASK
          value += digit << shift

          if continuation
            shift += VLQ_BASE_SHIFT
          else
            # Convert from VLQ signed representation
            negative = (value & 1) == 1
            value >>= 1
            value = -value if negative
            values << value

            # Reset for next value
            value = 0
            shift = 0
          end
        end

        values
      end

      # Encode an array of integers into a VLQ-encoded string
      def encode_vlq(values)
        return '' if values.nil? || values.empty?

        result = ''

        values.each do |value|
          # Convert to VLQ signed representation
          vlq = value < 0 ? ((-value) << 1) + 1 : value << 1

          loop do
            digit = vlq & VLQ_BASE_MASK
            vlq >>= VLQ_BASE_SHIFT
            digit |= VLQ_CONTINUATION_BIT if vlq > 0
            result += VLQ_BASE64_CHARS[digit]
            break if vlq == 0
          end
        end

        result
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

      def normalize_source_path_for_devtools(source, file_path)
        # Format source paths so they appear properly in browser DevTools
        # Chrome DevTools uses the source path to build the file tree
        return source if source.nil? || source.empty?

        # Remove any leading ./ for consistency
        source = source.sub(/^\.\//, '')

        # Handle absolute paths - make them relative to show properly
        if source.start_with?('/')
          # Extract just the relevant path (last few components)
          parts = source.split('/')
          # Keep last 3 path components for context (e.g., app/opal/controllers/...)
          source = parts.last(3).join('/')
        end

        # Prefix paths for user code (controllers, services, etc.) to group them
        # This ensures they appear under a dedicated folder in DevTools
        if source.include?('controllers/') || source.include?('services/')
          # Already has recognizable path, prefix with opal-sources for visibility
          "/opal-sources/#{source}"
        elsif source.start_with?('corelib/') || source.start_with?('opal/')
          # Opal core library files - put under opal-core
          "/opal-core/#{source}"
        elsif source.include?('opal_stimulus/') || source.include?('opal_vite/')
          # Opal library files
          "/opal-libs/#{source}"
        else
          # Other files (native.rb, js/proxy.rb, etc.)
          "/opal-other/#{source}"
        end
      end
    end
  end
end
