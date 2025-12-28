# Base64Helpers

Module providing Base64 encoding/decoding utilities using JavaScript's btoa/atob APIs.

## Usage

```ruby
class MyController < StimulusController
  include OpalVite::Concerns::V1::Base64Helpers

  def connect
    encoded = base64_encode("Hello, World!")
    puts encoded  # => "SGVsbG8sIFdvcmxkIQ=="

    decoded = base64_decode(encoded)
    puts decoded  # => "Hello, World!"
  end
end
```

## Basic Encoding/Decoding

### base64_encode(str)

Encode a string to Base64.

```ruby
base64_encode("Hello")  # => "SGVsbG8="
```

### base64_decode(str)

Decode a Base64 string.

```ruby
base64_decode("SGVsbG8=")  # => "Hello"
```

## URL-Safe Base64

URL-safe Base64 replaces `+` with `-`, `/` with `_`, and removes padding `=`.

### base64_encode_urlsafe(str)

Encode to URL-safe Base64.

```ruby
base64_encode_urlsafe("Hello+World/Test")
# Standard: "SGVsbG8rV29ybGQvVGVzdA=="
# URL-safe: "SGVsbG8rV29ybGQvVGVzdA"
```

### base64_decode_urlsafe(str)

Decode URL-safe Base64.

```ruby
base64_decode_urlsafe("SGVsbG8rV29ybGQvVGVzdA")  # => "Hello+World/Test"
```

## Unicode Support

Standard Base64 doesn't handle Unicode directly. These methods handle it properly.

### base64_encode_unicode(str)

Encode a Unicode string to Base64.

```ruby
base64_encode_unicode("日本語 🎉")  # Works with any Unicode
```

### base64_decode_unicode(str)

Decode a Base64 string to Unicode.

```ruby
base64_decode_unicode(encoded)  # => "日本語 🎉"
```

## Binary Data

### base64_encode_buffer(buffer)

Encode an ArrayBuffer or Uint8Array to Base64.

```ruby
buffer = `new Uint8Array([72, 101, 108, 108, 111])`
base64_encode_buffer(buffer)  # => "SGVsbG8="
```

### base64_decode_to_buffer(str)

Decode Base64 to Uint8Array.

```ruby
buffer = base64_decode_to_buffer("SGVsbG8=")
# Returns Uint8Array
```

## Data URLs

### to_data_url(content, mime_type)

Create a data URL from content.

```ruby
html = "<h1>Hello</h1>"
to_data_url(html, 'text/html')
# => "data:text/html;base64,PGgxPkhlbGxvPC9oMT4="
```

### parse_data_url(data_url)

Parse a data URL.

```ruby
result = parse_data_url("data:text/html;base64,PGgxPkhlbGxvPC9oMT4=")
# => { mime_type: "text/html", data: "<h1>Hello</h1>" }
```

## Authentication Helpers

### basic_auth_header(username, password)

Create a Basic Auth header value.

```ruby
basic_auth_header("admin", "secret123")
# => "Basic YWRtaW46c2VjcmV0MTIz"
```

### parse_basic_auth(header)

Parse a Basic Auth header value.

```ruby
result = parse_basic_auth("Basic YWRtaW46c2VjcmV0MTIz")
# => { username: "admin", password: "secret123" }
```

## JWT Helpers

::: warning
These methods only decode JWT tokens - they do NOT verify signatures. Use only for reading claims, not for authentication.
:::

### decode_jwt_payload(token)

Decode a JWT payload (without verification).

```ruby
payload = decode_jwt_payload(jwt_token)
# => { "sub" => "1234567890", "name" => "John Doe", "exp" => 1735689600 }
```

### jwt_expired?(token)

Check if a JWT is expired.

```ruby
jwt_expired?(token)  # => true/false
```

### jwt_expires_at(token)

Get JWT expiration time.

```ruby
expires_at = jwt_expires_at(token)
# Returns JavaScript Date object or nil
```

## Utility Methods

### valid_base64?(str)

Check if a string is valid Base64.

```ruby
valid_base64?("SGVsbG8=")  # => true
valid_base64?("invalid!")  # => false
```

### base64_decoded_length(str)

Get the decoded length of a Base64 string.

```ruby
base64_decoded_length("SGVsbG8=")  # => 5
```

## Common Use Cases

### Encoding Credentials for API Requests

```ruby
def fetch_with_auth
  auth_header = basic_auth_header(@username, @password)

  fetch_json('/api/data') do |data|
    # Handle response
  end
end
```

### Working with Data URLs for Images

```ruby
def create_image_data_url(image_data)
  to_data_url(image_data, 'image/png')
end
```

### Handling JWT Tokens

```ruby
def check_token_validity(token)
  return false if jwt_expired?(token)

  payload = decode_jwt_payload(token)
  return false unless payload

  # Check other claims
  payload['role'] == 'admin'
end
```
