require 'json'

module Opal
  module Vite
    class Config
      # Options passed on to Opal's compiler (see #explicit_compiler_options)
      COMPILER_OPTION_KEYS = %i[arity_check freezing esm dynamic_require_severity missing_require_severity].freeze

      attr_accessor :source_map_enabled

      attr_reader(*COMPILER_OPTION_KEYS)

      COMPILER_OPTION_KEYS.each do |key|
        define_method(:"#{key}=") do |value|
          @explicit_compiler_options[key] = value
          instance_variable_set(:"@#{key}", value)
        end
      end

      def initialize
        @explicit_compiler_options = {}
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

      # Compiler options that were set explicitly (via a writer, a config file
      # or Opal::Vite.configure). Unset ones are left to Opal's own defaults, so
      # the output does not change unless the user asked for it.
      def explicit_compiler_options
        @explicit_compiler_options.to_h do |key, value|
          # Severities arrive as strings when read from a JSON config file
          [key, key.to_s.end_with?('_severity') && value ? value.to_sym : value]
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
