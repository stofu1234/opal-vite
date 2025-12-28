# Utilities App

Demonstrates opal-vite stdlib helper modules and StimulusHelpers utilities.

## Features Demonstrated

### URIHelpers
- URL parsing (`parse_url`, `url_hostname`, `url_pathname`, etc.)
- Query parameter manipulation (`url_param`, `url_set_param`, `url_all_params`)
- URL building (`build_url`, `build_query_string`)
- Encoding/decoding (`encode_uri_component`, `decode_uri_component`)

### Base64Helpers
- Basic encoding/decoding (`base64_encode`, `base64_decode`)
- URL-safe Base64 (`base64_encode_urlsafe`, `base64_decode_urlsafe`)
- Unicode support (`base64_encode_unicode`, `base64_decode_unicode`)
- Data URLs (`to_data_url`, `parse_data_url`)
- JWT decoding (`decode_jwt_payload`, `jwt_expired?`)
- Basic Auth (`basic_auth_header`, `parse_basic_auth`)

### StimulusHelpers Utilities
- **Debounce/Throttle**: `debounce`, `throttle`, `debounced`, `throttled`
- **Clipboard**: `copy_to_clipboard`, `read_from_clipboard`
- **Object utilities**: `deep_clone`, `deep_merge`, `pick`, `omit`
- **Set utilities**: `unique`, `intersection`, `difference`, `union`
- **Validation**: `valid_email?`, `valid_url?`, `valid_phone?`, `blank?`, `present?`
- **Console helpers**: `console_styled`, `console_group`, `console_table`

## Running

```bash
bundle install
pnpm install
pnpm dev
```

Open http://localhost:3008

## Directory Structure

```
utilities-app/
├── app/opal/
│   ├── application.rb
│   └── controllers/
│       ├── url_demo_controller.rb
│       ├── base64_demo_controller.rb
│       ├── validation_demo_controller.rb
│       └── clipboard_demo_controller.rb
├── src/
│   └── main.js
├── index.html
├── package.json
├── vite.config.ts
└── Gemfile
```
