# backtick_javascript: true

# Base64DemoController - Demonstrates Base64Helpers module
#
# Features:
# - Basic encoding/decoding
# - URL-safe Base64
# - Unicode support
# - Data URLs
# - JWT decoding
# - Basic Auth
#
class Base64DemoController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::Base64Helpers

  self.targets = ["input", "output", "jwtInput", "authUser", "authPass"]

  def connect
    puts "Base64DemoController connected"
  end

  # Action: Encode to Base64
  def encode
    text = target_value(:input)
    return if blank?(text)

    encoded = base64_encode(text)
    if encoded
      show_output("Encoded: <code class='bg-gray-100 px-2 py-1 rounded'>#{encoded}</code>")
    else
      show_output("Encoding failed", "error")
    end
  end

  # Action: Decode from Base64
  def decode
    text = target_value(:input)
    return if blank?(text)

    decoded = base64_decode(text)
    if decoded
      show_output("Decoded: <code class='bg-gray-100 px-2 py-1 rounded'>#{decoded}</code>")
    else
      show_output("Decoding failed - invalid Base64", "error")
    end
  end

  # Action: URL-safe encoding demo
  def urlsafe_demo
    text = target_value(:input)
    text = "Hello+World/Test==" if blank?(text)

    standard = base64_encode(text)
    urlsafe = base64_encode_urlsafe(text)
    recovered = base64_decode_urlsafe(urlsafe)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Original:</strong> #{text}</div>
        <div><strong>Standard Base64:</strong> <code>#{standard}</code></div>
        <div><strong>URL-safe Base64:</strong> <code>#{urlsafe}</code></div>
        <div><strong>Decoded back:</strong> #{recovered}</div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Unicode encoding demo
  def unicode_demo
    text = "日本語テスト 🎉 émojis"

    encoded = base64_encode_unicode(text)
    decoded = base64_decode_unicode(encoded)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Original (Unicode):</strong> #{text}</div>
        <div><strong>Base64 Encoded:</strong> <code>#{encoded}</code></div>
        <div><strong>Decoded:</strong> #{decoded}</div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Data URL demo
  def data_url_demo
    html_content = "<h1>Hello from Data URL!</h1><p>This is embedded content.</p>"

    data_url = to_data_url(html_content, 'text/html')
    parsed = parse_data_url(data_url)

    output = <<~HTML
      <div class="space-y-4">
        <div>
          <strong>Original HTML:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{html_content}</pre>
        </div>
        <div>
          <strong>Data URL:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm break-all">#{data_url}</pre>
        </div>
        <div>
          <strong>Parsed back:</strong>
          <div>MIME Type: #{parsed[:mime_type]}</div>
          <div>Data: #{parsed[:data]}</div>
        </div>
        <div>
          <a href="#{data_url}" target="_blank" class="text-blue-500 hover:underline">
            Open Data URL in new tab
          </a>
        </div>
      </div>
    HTML

    show_output(output)
  end

  # Action: JWT decoding demo
  def decode_jwt
    jwt = target_value(:jwtInput)

    # Use example JWT if empty
    if blank?(jwt)
      # Example JWT (not a real token - just for demo)
      jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZXhwIjoxNzM1Njg5NjAwLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
      target_set_value(:jwtInput, jwt)
    end

    payload = decode_jwt_payload(jwt)

    unless payload
      show_output("Failed to decode JWT - invalid format", "error")
      return
    end

    expired = jwt_expired?(jwt)
    expires_at = jwt_expires_at(jwt)
    expires_str = expires_at ? `#{expires_at}.toISOString()` : "No expiration"

    output = <<~HTML
      <div class="space-y-4">
        <div>
          <strong>Payload:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{payload}, null, 2)`}</pre>
        </div>
        <div>
          <strong>Expired:</strong>
          <span class="#{expired ? 'text-red-600' : 'text-green-600'}">
            #{expired ? 'Yes' : 'No'}
          </span>
        </div>
        <div>
          <strong>Expires at:</strong> #{expires_str}
        </div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Basic Auth demo
  def basic_auth_demo
    username = target_value(:authUser)
    password = target_value(:authPass)

    username = "admin" if blank?(username)
    password = "secret123" if blank?(password)

    header = basic_auth_header(username, password)
    parsed = parse_basic_auth(header)

    output = <<~HTML
      <div class="space-y-4">
        <div>
          <strong>Credentials:</strong> #{username}:#{password}
        </div>
        <div>
          <strong>Authorization Header:</strong>
          <code class="bg-gray-100 px-2 py-1 rounded">#{header}</code>
        </div>
        <div>
          <strong>Parsed back:</strong>
          <div>Username: #{parsed[:username]}</div>
          <div>Password: #{parsed[:password]}</div>
        </div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Validation demo
  def validate_base64
    text = target_value(:input)
    return if blank?(text)

    valid = valid_base64?(text)
    length = valid ? base64_decoded_length(text) : 0

    output = <<~HTML
      <div class="space-y-2">
        <div>
          <strong>Valid Base64:</strong>
          <span class="#{valid ? 'text-green-600' : 'text-red-600'}">
            #{valid ? 'Yes' : 'No'}
          </span>
        </div>
        #{valid ? "<div><strong>Decoded length:</strong> #{length} bytes</div>" : ""}
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
