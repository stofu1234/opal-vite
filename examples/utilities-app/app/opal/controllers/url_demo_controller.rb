# backtick_javascript: true

# UrlDemoController - Demonstrates URIHelpers module
#
# Features:
# - URL parsing and component extraction
# - Query parameter manipulation
# - URL building
# - Encoding/decoding
#
class UrlDemoController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::URIHelpers

  self.targets = ["urlInput", "output", "paramKey", "paramValue"]

  def connect
    puts "UrlDemoController connected"
    # Parse current page URL by default
    parse_current
  end

  # Action: Parse the URL in the input
  def parse
    url_string = target_value(:urlInput)
    return if blank?(url_string)

    url = parse_url(url_string)
    unless url
      show_output("Invalid URL", "error")
      return
    end

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Protocol:</strong> #{url_protocol(url)}</div>
        <div><strong>Hostname:</strong> #{url_hostname(url)}</div>
        <div><strong>Port:</strong> #{url_port(url) || '(default)'}</div>
        <div><strong>Pathname:</strong> #{url_pathname(url)}</div>
        <div><strong>Search:</strong> #{url_search(url) || '(none)'}</div>
        <div><strong>Hash:</strong> #{url_hash(url) || '(none)'}</div>
        <div><strong>Origin:</strong> #{url_origin(url)}</div>
      </div>
    HTML

    # Add query parameters if any
    params = url_all_params(url)
    unless params.empty?
      params_html = params.map { |k, v| "<li><code>#{k}</code> = <code>#{v}</code></li>" }.join
      output += <<~HTML
        <div class="mt-4">
          <strong>Query Parameters:</strong>
          <ul class="list-disc list-inside ml-4">#{params_html}</ul>
        </div>
      HTML
    end

    show_output(output)
  end

  # Action: Parse current page URL
  def parse_current
    url = current_url
    target_set_value(:urlInput, url_to_string(url))
    parse
  end

  # Action: Add a query parameter
  def add_param
    url_string = target_value(:urlInput)
    key = target_value(:paramKey)
    value = target_value(:paramValue)

    return if blank?(url_string) || blank?(key)

    url = parse_url(url_string)
    return unless url

    url_set_param(url, key, value || '')
    target_set_value(:urlInput, url_to_string(url))

    # Clear param inputs
    target_set_value(:paramKey, '')
    target_set_value(:paramValue, '')

    parse
  end

  # Action: Build a URL from scratch
  def build_example
    built_url = build_url(
      protocol: 'https:',
      hostname: 'api.example.com',
      port: '8080',
      pathname: '/v1/users',
      params: { page: '1', limit: '10', sort: 'name' },
      hash: '#results'
    )

    target_set_value(:urlInput, built_url)
    parse
  end

  # Action: Demonstrate encoding
  def encode_demo
    original = "Hello World! こんにちは 你好"
    encoded = encode_uri_component(original)
    decoded = decode_uri_component(encoded)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Original:</strong> #{original}</div>
        <div><strong>Encoded:</strong> <code>#{encoded}</code></div>
        <div><strong>Decoded:</strong> #{decoded}</div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Parse query string demo
  def query_string_demo
    query = "name=John&age=30&tags=ruby&tags=javascript"
    parsed = parse_query_string(query)

    rebuilt = build_query_string({ name: 'Jane', age: '25', city: 'Tokyo' })

    output = <<~HTML
      <div class="space-y-4">
        <div>
          <strong>Parse "#{query}":</strong>
          <pre class="bg-gray-100 p-2 rounded mt-1">#{`JSON.stringify(#{parsed.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>Build from {name: 'Jane', age: '25', city: 'Tokyo'}:</strong>
          <pre class="bg-gray-100 p-2 rounded mt-1">#{rebuilt}</pre>
        </div>
      </div>
    HTML

    show_output(output)
  end

  private

  def show_output(html, type = "success")
    return unless has_target?(:output)

    color = type == "error" ? "text-red-600" : "text-gray-800"
    target_set_html(:output, "<div class='#{color}'>#{html}</div>")
  end
end
