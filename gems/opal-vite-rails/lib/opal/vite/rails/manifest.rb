require "json"

module Opal
  module Vite
    module Rails
      class Manifest
        def initialize(manifest_path = nil)
          @manifest_path = manifest_path || default_manifest_path
          @data = load_manifest
        end

        def lookup(name)
          # Try exact match first
          entry = @data[name]
          return entry if entry

          # Try with .rb extension
          entry = @data["#{name}.rb"]
          return entry if entry

          # Try without extension
          name_without_ext = name.sub(/\.(rb|js)$/, '')
          entry = @data[name_without_ext]
          return entry if entry

          # Not found
          nil
        end

        def [](name)
          entry = lookup(name)
          entry && entry['file']
        end

        def reload!
          @data = load_manifest
        end

        private

        def default_manifest_path
          if defined?(::ViteRuby) && ::ViteRuby.instance.config.respond_to?(:manifest_paths)
            vite_config = ::ViteRuby.instance.config
            vite_config.manifest_paths.first ||
              vite_config.build_output_dir.join('.vite', 'manifest.json')
          elsif defined?(::Rails)
            ::Rails.public_path.join('vite', 'manifest.json')
          else
            'public/vite/manifest.json'
          end
        end

        def load_manifest
          return {} unless File.exist?(@manifest_path)

          JSON.parse(File.read(@manifest_path))
        rescue JSON::ParserError => e
          warn "Failed to parse Vite manifest at #{@manifest_path}: #{e.message}"
          {}
        end
      end
    end
  end
end
