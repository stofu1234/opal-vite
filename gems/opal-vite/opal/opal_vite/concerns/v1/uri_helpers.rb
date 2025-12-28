# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # URIHelpers - provides URL parsing and manipulation utilities
      #
      # This module wraps JavaScript's URL and URLSearchParams APIs
      # to provide Ruby-friendly methods for URL operations.
      #
      # @example Basic usage
      #   class MyController < StimulusController
      #     include OpalVite::Concerns::V1::URIHelpers
      #
      #     def connect
      #       url = parse_url("https://example.com/path?foo=bar")
      #       puts url_hostname(url)  # => "example.com"
      #       puts url_param(url, "foo")  # => "bar"
      #     end
      #   end
      #
      module URIHelpers
        # ===== URL Parsing =====

        # Parse a URL string into a URL object
        # @param url_string [String] URL string to parse
        # @return [Native] JavaScript URL object
        def parse_url(url_string)
          `new URL(#{url_string})`
        rescue
          nil
        end

        # Parse a URL with a base URL
        # @param url_string [String] Relative or absolute URL
        # @param base [String] Base URL
        # @return [Native] JavaScript URL object
        def parse_url_with_base(url_string, base)
          `new URL(#{url_string}, #{base})`
        rescue
          nil
        end

        # Get the current page URL
        # @return [Native] JavaScript URL object
        def current_url
          `new URL(window.location.href)`
        end

        # ===== URL Components =====

        # Get the protocol (scheme) of a URL
        # @param url [Native] URL object
        # @return [String] Protocol (e.g., "https:")
        def url_protocol(url)
          `#{url}.protocol`
        end

        # Get the hostname of a URL
        # @param url [Native] URL object
        # @return [String] Hostname (e.g., "example.com")
        def url_hostname(url)
          `#{url}.hostname`
        end

        # Get the host (hostname + port) of a URL
        # @param url [Native] URL object
        # @return [String] Host (e.g., "example.com:8080")
        def url_host(url)
          `#{url}.host`
        end

        # Get the port of a URL
        # @param url [Native] URL object
        # @return [String] Port number or empty string
        def url_port(url)
          `#{url}.port`
        end

        # Get the pathname of a URL
        # @param url [Native] URL object
        # @return [String] Pathname (e.g., "/path/to/page")
        def url_pathname(url)
          `#{url}.pathname`
        end

        # Get the search string (query string with ?)
        # @param url [Native] URL object
        # @return [String] Search string (e.g., "?foo=bar")
        def url_search(url)
          `#{url}.search`
        end

        # Get the hash (fragment) of a URL
        # @param url [Native] URL object
        # @return [String] Hash (e.g., "#section")
        def url_hash(url)
          `#{url}.hash`
        end

        # Get the origin of a URL
        # @param url [Native] URL object
        # @return [String] Origin (e.g., "https://example.com")
        def url_origin(url)
          `#{url}.origin`
        end

        # Get the full URL as a string
        # @param url [Native] URL object
        # @return [String] Full URL string
        def url_to_string(url)
          `#{url}.href`
        end

        # ===== Query Parameters =====

        # Get a query parameter value
        # @param url [Native] URL object
        # @param name [String] Parameter name
        # @return [String, nil] Parameter value or nil
        def url_param(url, name)
          result = `#{url}.searchParams.get(#{name})`
          `#{result} === null` ? nil : result
        end

        # Get all values for a query parameter
        # @param url [Native] URL object
        # @param name [String] Parameter name
        # @return [Array<String>] Array of values
        def url_params(url, name)
          `Array.from(#{url}.searchParams.getAll(#{name}))`
        end

        # Check if a query parameter exists
        # @param url [Native] URL object
        # @param name [String] Parameter name
        # @return [Boolean] True if parameter exists
        def url_has_param?(url, name)
          `#{url}.searchParams.has(#{name})`
        end

        # Get all query parameters as a Hash
        # @param url [Native] URL object
        # @return [Hash] Hash of parameter names to values
        def url_all_params(url)
          result = {}
          `#{url}.searchParams.forEach((value, key) => {
            #{result[`key`] = `value`}
          })`
          result
        end

        # Set a query parameter (mutates the URL object)
        # @param url [Native] URL object
        # @param name [String] Parameter name
        # @param value [String] Parameter value
        def url_set_param(url, name, value)
          `#{url}.searchParams.set(#{name}, #{value})`
        end

        # Append a query parameter (allows duplicates)
        # @param url [Native] URL object
        # @param name [String] Parameter name
        # @param value [String] Parameter value
        def url_append_param(url, name, value)
          `#{url}.searchParams.append(#{name}, #{value})`
        end

        # Delete a query parameter
        # @param url [Native] URL object
        # @param name [String] Parameter name
        def url_delete_param(url, name)
          `#{url}.searchParams.delete(#{name})`
        end

        # ===== URL Building =====

        # Build a URL from components
        # @param options [Hash] URL components
        # @option options [String] :protocol Protocol (default: "https:")
        # @option options [String] :hostname Hostname (required)
        # @option options [String] :port Port number
        # @option options [String] :pathname Path
        # @option options [Hash] :params Query parameters
        # @option options [String] :hash Fragment
        # @return [String] Built URL string
        def build_url(options = {})
          protocol = options[:protocol] || 'https:'
          hostname = options[:hostname] || 'localhost'
          port = options[:port]
          pathname = options[:pathname] || '/'
          params = options[:params] || {}
          hash = options[:hash]

          # Build base URL
          base = "#{protocol}//#{hostname}"
          base += ":#{port}" if port && !port.to_s.empty?
          base += pathname

          url = parse_url(base)
          return nil unless url

          # Add query parameters
          params.each do |key, value|
            url_set_param(url, key.to_s, value.to_s)
          end

          # Add hash
          `#{url}.hash = #{hash}` if hash

          url_to_string(url)
        end

        # ===== URL Encoding =====

        # Encode a URI component
        # @param str [String] String to encode
        # @return [String] Encoded string
        def encode_uri_component(str)
          `encodeURIComponent(#{str})`
        end

        # Decode a URI component
        # @param str [String] String to decode
        # @return [String] Decoded string
        def decode_uri_component(str)
          `decodeURIComponent(#{str})`
        rescue
          str
        end

        # Encode a full URI
        # @param str [String] URI to encode
        # @return [String] Encoded URI
        def encode_uri(str)
          `encodeURI(#{str})`
        end

        # Decode a full URI
        # @param str [String] URI to decode
        # @return [String] Decoded URI
        def decode_uri(str)
          `decodeURI(#{str})`
        rescue
          str
        end

        # ===== Query String Utilities =====

        # Parse a query string into a Hash
        # @param query_string [String] Query string (with or without leading ?)
        # @return [Hash] Parsed parameters
        def parse_query_string(query_string)
          # Remove leading ? if present
          qs = query_string.to_s
          qs = qs[1..-1] if qs.start_with?('?')

          result = {}
          params = `new URLSearchParams(#{qs})`
          `#{params}.forEach((value, key) => {
            #{result[`key`] = `value`}
          })`
          result
        end

        # Build a query string from a Hash
        # @param params [Hash] Parameters
        # @return [String] Query string (without leading ?)
        def build_query_string(params)
          search_params = `new URLSearchParams()`
          params.each do |key, value|
            `#{search_params}.append(#{key.to_s}, #{value.to_s})`
          end
          `#{search_params}.toString()`
        end

        # ===== Path Utilities =====

        # Join path segments
        # @param segments [Array<String>] Path segments
        # @return [String] Joined path
        def join_path(*segments)
          segments.map { |s| s.to_s.gsub(%r{^/|/$}, '') }.reject(&:empty?).join('/')
        end

        # Get the filename from a path
        # @param path [String] Path
        # @return [String] Filename
        def path_basename(path)
          path.to_s.split('/').last || ''
        end

        # Get the directory from a path
        # @param path [String] Path
        # @return [String] Directory path
        def path_dirname(path)
          parts = path.to_s.split('/')
          parts.pop
          parts.join('/') || '/'
        end

        # Get the file extension from a path
        # @param path [String] Path
        # @return [String] Extension (with dot) or empty string
        def path_extname(path)
          basename = path_basename(path)
          idx = basename.rindex('.')
          idx ? basename[idx..-1] : ''
        end
      end
    end
  end
end

# Alias for convenience
URIHelpers = OpalVite::Concerns::V1::URIHelpers
