# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # Storable concern - provides LocalStorage functionality
      module Storable
      def storage_get(key)
        stored = `localStorage.getItem(#{key})`
        return nil unless stored

        begin
          `JSON.parse(stored)`
        rescue
          nil
        end
      end

      def storage_set(key, data)
        json = `JSON.stringify(#{data.to_n})`
        `localStorage.setItem(#{key}, json)`
      end

      def storage_remove(key)
        `localStorage.removeItem(#{key})`
      end
      end
    end
  end
end

# Alias for backward compatibility
Storable = OpalVite::Concerns::V1::Storable
