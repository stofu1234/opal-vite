require 'json'

module Opal
  module Vite
    class SourceMapValidator
      # Validate a source map JSON string
      def self.valid?(source_map_json)
        return false if source_map_json.nil? || source_map_json.empty?

        begin
          map = JSON.parse(source_map_json)

          # Check required fields
          return false unless map['version']
          return false unless map['sources']
          return false unless map['mappings']

          true
        rescue JSON::ParserError
          false
        end
      end

      # Get information about a source map
      def self.info(source_map_json)
        return nil unless valid?(source_map_json)

        map = JSON.parse(source_map_json)
        {
          version: map['version'],
          sources: map['sources'],
          sources_count: map['sources']&.length || 0,
          has_names: !map['names'].nil?,
          has_source_content: !map['sourcesContent'].nil?
        }
      end
    end
  end
end
