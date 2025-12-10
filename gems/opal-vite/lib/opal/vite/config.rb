require 'json'

module Opal
  module Vite
    class Config
      attr_accessor :source_map_enabled,
                    :arity_check,
                    :freezing,
                    :esm,
                    :dynamic_require_severity,
                    :missing_require_severity

      def initialize
        @source_map_enabled = true
        @arity_check = false
        @freezing = true
        @esm = true
        @dynamic_require_severity = :ignore
        @missing_require_severity = :error
      end

      def self.load_from_file(path)
        config = new
        if File.exist?(path)
          data = JSON.parse(File.read(path))
          config.apply_hash(data)
        end
        config
      end

      def apply_hash(hash)
        hash.each do |key, value|
          setter = "#{key}="
          send(setter, value) if respond_to?(setter)
        end
      end

      def to_compiler_options
        {
          source_map_enabled: source_map_enabled,
          arity_check: arity_check,
          freezing: freezing,
          esm: esm,
          dynamic_require_severity: dynamic_require_severity,
          missing_require_severity: missing_require_severity
        }
      end
    end
  end
end
