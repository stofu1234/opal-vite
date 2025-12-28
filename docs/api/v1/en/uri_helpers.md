# URIHelpers

Module providing URL parsing and manipulation utilities using JavaScript's URL and URLSearchParams APIs.

## Usage

```ruby
class MyController < StimulusController
  include OpalVite::Concerns::V1::URIHelpers

  def connect
    url = parse_url("https://example.com/path?foo=bar")
    puts url_hostname(url)  # => "example.com"
    puts url_param(url, "foo")  # => "bar"
  end
end
```

## URL Parsing

### parse_url(url_string)

Parse a URL string into a URL object.

```ruby
url = parse_url("https://example.com:8080/path?query=value#hash")
# Returns JavaScript URL object, or nil if invalid
```

### parse_url_with_base(url_string, base)

Parse a URL with a base URL.

```ruby
url = parse_url_with_base("/api/users", "https://example.com")
url_to_string(url)  # => "https://example.com/api/users"
```

### current_url

Get the current page URL.

```ruby
url = current_url
puts url_pathname(url)  # Current page path
```

## URL Components

### url_protocol(url)

Get the protocol (scheme) of a URL.

```ruby
url_protocol(url)  # => "https:"
```

### url_hostname(url)

Get the hostname.

```ruby
url_hostname(url)  # => "example.com"
```

### url_host(url)

Get the host (hostname + port).

```ruby
url_host(url)  # => "example.com:8080"
```

### url_port(url)

Get the port number.

```ruby
url_port(url)  # => "8080" or ""
```

### url_pathname(url)

Get the pathname.

```ruby
url_pathname(url)  # => "/path/to/page"
```

### url_search(url)

Get the search string (query string with ?).

```ruby
url_search(url)  # => "?foo=bar&baz=qux"
```

### url_hash(url)

Get the hash (fragment).

```ruby
url_hash(url)  # => "#section"
```

### url_origin(url)

Get the origin.

```ruby
url_origin(url)  # => "https://example.com:8080"
```

### url_to_string(url)

Get the full URL as a string.

```ruby
url_to_string(url)  # => "https://example.com:8080/path?query=value#hash"
```

## Query Parameters

### url_param(url, name)

Get a query parameter value.

```ruby
url_param(url, "page")  # => "1" or nil
```

### url_params(url, name)

Get all values for a query parameter (for multi-value params).

```ruby
url_params(url, "tags")  # => ["ruby", "javascript"]
```

### url_has_param?(url, name)

Check if a query parameter exists.

```ruby
url_has_param?(url, "page")  # => true/false
```

### url_all_params(url)

Get all query parameters as a Hash.

```ruby
params = url_all_params(url)
# => { "page" => "1", "limit" => "10" }
```

### url_set_param(url, name, value)

Set a query parameter (mutates the URL object).

```ruby
url_set_param(url, "page", "2")
```

### url_append_param(url, name, value)

Append a query parameter (allows duplicates).

```ruby
url_append_param(url, "tag", "ruby")
url_append_param(url, "tag", "javascript")
```

### url_delete_param(url, name)

Delete a query parameter.

```ruby
url_delete_param(url, "page")
```

## URL Building

### build_url(options)

Build a URL from components.

```ruby
url = build_url(
  protocol: 'https:',
  hostname: 'api.example.com',
  port: '8080',
  pathname: '/v1/users',
  params: { page: '1', limit: '10' },
  hash: '#results'
)
# => "https://api.example.com:8080/v1/users?page=1&limit=10#results"
```

## URL Encoding

### encode_uri_component(str)

Encode a URI component.

```ruby
encode_uri_component("hello world")  # => "hello%20world"
```

### decode_uri_component(str)

Decode a URI component.

```ruby
decode_uri_component("hello%20world")  # => "hello world"
```

### encode_uri(str)

Encode a full URI.

```ruby
encode_uri("https://example.com/path with spaces")
```

### decode_uri(str)

Decode a full URI.

```ruby
decode_uri("https://example.com/path%20with%20spaces")
```

## Query String Utilities

### parse_query_string(query_string)

Parse a query string into a Hash.

```ruby
parse_query_string("name=John&age=30")
# => { "name" => "John", "age" => "30" }
```

### build_query_string(params)

Build a query string from a Hash.

```ruby
build_query_string({ name: 'John', age: 30 })
# => "name=John&age=30"
```

## Path Utilities

### join_path(*segments)

Join path segments.

```ruby
join_path("api", "v1", "users")  # => "api/v1/users"
```

### path_basename(path)

Get the filename from a path.

```ruby
path_basename("/path/to/file.txt")  # => "file.txt"
```

### path_dirname(path)

Get the directory from a path.

```ruby
path_dirname("/path/to/file.txt")  # => "/path/to"
```

### path_extname(path)

Get the file extension.

```ruby
path_extname("/path/to/file.txt")  # => ".txt"
```
