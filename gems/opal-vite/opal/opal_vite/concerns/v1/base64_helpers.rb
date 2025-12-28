# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # Base64Helpers - provides Base64 encoding/decoding utilities
      #
      # This module wraps JavaScript's btoa/atob and provides additional
      # utilities for Base64 operations commonly needed in web applications.
      #
      # @example Basic usage
      #   class MyController < StimulusController
      #     include OpalVite::Concerns::V1::Base64Helpers
      #
      #     def connect
      #       encoded = base64_encode("Hello, World!")
      #       puts encoded  # => "SGVsbG8sIFdvcmxkIQ=="
      #
      #       decoded = base64_decode(encoded)
      #       puts decoded  # => "Hello, World!"
      #     end
      #   end
      #
      module Base64Helpers
        # ===== Basic Encoding/Decoding =====

        # Encode a string to Base64
        # @param str [String] String to encode
        # @return [String] Base64 encoded string
        def base64_encode(str)
          `btoa(#{str})`
        rescue
          nil
        end

        # Decode a Base64 string
        # @param str [String] Base64 string to decode
        # @return [String] Decoded string
        def base64_decode(str)
          `atob(#{str})`
        rescue
          nil
        end

        # ===== URL-Safe Base64 =====

        # Encode a string to URL-safe Base64
        # @param str [String] String to encode
        # @return [String] URL-safe Base64 encoded string
        def base64_encode_urlsafe(str)
          encoded = base64_encode(str)
          return nil unless encoded

          # Replace + with -, / with _, and remove =
          encoded.gsub('+', '-').gsub('/', '_').gsub('=', '')
        end

        # Decode a URL-safe Base64 string
        # @param str [String] URL-safe Base64 string to decode
        # @return [String] Decoded string
        def base64_decode_urlsafe(str)
          # Restore standard Base64 characters
          standard = str.gsub('-', '+').gsub('_', '/')

          # Add padding if needed
          case standard.length % 4
          when 2
            standard += '=='
          when 3
            standard += '='
          end

          base64_decode(standard)
        end

        # ===== Unicode Support =====

        # Encode a Unicode string to Base64
        # @param str [String] Unicode string to encode
        # @return [String] Base64 encoded string
        def base64_encode_unicode(str)
          # Convert to UTF-8 bytes, then encode
          `btoa(unescape(encodeURIComponent(#{str})))`
        rescue
          nil
        end

        # Decode a Base64 string to Unicode
        # @param str [String] Base64 string to decode
        # @return [String] Decoded Unicode string
        def base64_decode_unicode(str)
          `decodeURIComponent(escape(atob(#{str})))`
        rescue
          nil
        end

        # ===== Binary Data (ArrayBuffer/Uint8Array) =====

        # Encode an ArrayBuffer or Uint8Array to Base64
        # @param buffer [Native] ArrayBuffer or Uint8Array
        # @return [String] Base64 encoded string
        def base64_encode_buffer(buffer)
          `
            var bytes = new Uint8Array(#{buffer});
            var binary = '';
            for (var i = 0; i < bytes.byteLength; i++) {
              binary += String.fromCharCode(bytes[i]);
            }
            return btoa(binary);
          `
        rescue
          nil
        end

        # Decode a Base64 string to Uint8Array
        # @param str [String] Base64 string to decode
        # @return [Native] Uint8Array
        def base64_decode_to_buffer(str)
          `
            var binary = atob(#{str});
            var bytes = new Uint8Array(binary.length);
            for (var i = 0; i < binary.length; i++) {
              bytes[i] = binary.charCodeAt(i);
            }
            return bytes;
          `
        rescue
          nil
        end

        # ===== Data URL Support =====

        # Create a data URL from content
        # @param content [String] Content to encode
        # @param mime_type [String] MIME type (default: "text/plain")
        # @return [String] Data URL
        def to_data_url(content, mime_type = 'text/plain')
          encoded = base64_encode_unicode(content)
          return nil unless encoded

          "data:#{mime_type};base64,#{encoded}"
        end

        # Parse a data URL
        # @param data_url [String] Data URL
        # @return [Hash, nil] Hash with :mime_type and :data keys, or nil
        def parse_data_url(data_url)
          return nil unless data_url.to_s.start_with?('data:')

          match = `#{data_url}.match(/^data:([^;]+);base64,(.+)$/)`
          return nil if `#{match} === null`

          {
            mime_type: `#{match}[1]`,
            data: base64_decode_unicode(`#{match}[2]`)
          }
        end

        # ===== Authentication Helpers =====

        # Create a Basic Auth header value
        # @param username [String] Username
        # @param password [String] Password
        # @return [String] Basic auth header value
        def basic_auth_header(username, password)
          credentials = "#{username}:#{password}"
          encoded = base64_encode(credentials)
          "Basic #{encoded}"
        end

        # Parse a Basic Auth header value
        # @param header [String] Authorization header value
        # @return [Hash, nil] Hash with :username and :password keys, or nil
        def parse_basic_auth(header)
          return nil unless header.to_s.start_with?('Basic ')

          encoded = header[6..-1]
          decoded = base64_decode(encoded)
          return nil unless decoded

          parts = decoded.split(':', 2)
          return nil if parts.length != 2

          {
            username: parts[0],
            password: parts[1]
          }
        end

        # ===== JWT Helpers =====

        # Decode a JWT payload (without verification)
        # @param token [String] JWT token
        # @return [Hash, nil] Decoded payload or nil
        # @note This does NOT verify the signature - use only for reading claims
        def decode_jwt_payload(token)
          parts = token.to_s.split('.')
          return nil if parts.length != 3

          payload_base64 = parts[1]
          payload_json = base64_decode_urlsafe(payload_base64)
          return nil unless payload_json

          `JSON.parse(#{payload_json})`
        rescue
          nil
        end

        # Check if a JWT is expired
        # @param token [String] JWT token
        # @return [Boolean] True if expired
        def jwt_expired?(token)
          payload = decode_jwt_payload(token)
          return true unless payload

          exp = `#{payload}.exp`
          return false if `#{exp} === undefined || #{exp} === null`

          now = `Math.floor(Date.now() / 1000)`
          `#{exp} < #{now}`
        end

        # Get JWT expiration time
        # @param token [String] JWT token
        # @return [Time, nil] Expiration time or nil
        def jwt_expires_at(token)
          payload = decode_jwt_payload(token)
          return nil unless payload

          exp = `#{payload}.exp`
          return nil if `#{exp} === undefined || #{exp} === null`

          # Convert Unix timestamp to Ruby-like time representation
          `new Date(#{exp} * 1000)`
        end

        # ===== Utility Methods =====

        # Check if a string is valid Base64
        # @param str [String] String to check
        # @return [Boolean] True if valid Base64
        def valid_base64?(str)
          return false if str.nil? || str.empty?

          # Check for valid Base64 characters
          `
            var regex = /^[A-Za-z0-9+/]*={0,2}$/;
            if (!regex.test(#{str})) return false;
            if (#{str}.length % 4 !== 0) return false;
            try {
              atob(#{str});
              return true;
            } catch (e) {
              return false;
            }
          `
        end

        # Get the decoded length of a Base64 string
        # @param str [String] Base64 string
        # @return [Integer] Decoded length in bytes
        def base64_decoded_length(str)
          return 0 if str.nil? || str.empty?

          len = str.length
          padding = str.end_with?('==') ? 2 : (str.end_with?('=') ? 1 : 0)
          (len * 3 / 4) - padding
        end
      end
    end
  end
end

# Alias for convenience
Base64Helpers = OpalVite::Concerns::V1::Base64Helpers
