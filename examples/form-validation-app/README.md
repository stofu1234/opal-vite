# Form Validation Example

A comprehensive form validation example built with Opal, Stimulus, and Vite, demonstrating real-time client-side validation with multiple validation rules and async validation.

## Features

- **Real-time Validation**: Validates fields on blur and clears errors on input
- **Multiple Validation Rules**:
  - `required` - Field must not be empty
  - `minLength` - Minimum character length
  - `maxLength` - Maximum character length
  - `email` - Valid email format
  - `alphanumeric` - Only letters and numbers
  - `numeric` - Numbers only
  - `min` / `max` - Numeric range validation
  - `password` - Strong password (uppercase, lowercase, number)
  - `phone` - Valid phone number format
  - `url` - Valid URL format
  - `matches` - Field matching (e.g., password confirmation)
- **Async Validation**: Email availability check with simulated API call
- **Live Stats**: Real-time tracking of validation state
- **Custom Error Messages**: User-friendly messages for each rule
- **Visual Feedback**: Clear error states and field hints

## Getting Started

### Prerequisites

- Node.js 18+
- Ruby 3.0+
- pnpm (or npm/yarn)

### Installation

```bash
# Install dependencies
pnpm install
bundle install

# Start dev server
pnpm dev
```

The app will be available at `http://localhost:3011`

## Project Structure

```
form-validation-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # JavaScript entry point
│   ├── opal/
│   │   ├── application.rb           # Opal entry point
│   │   └── controllers/
│   │       └── form_validation_controller.rb  # Main controller
│   └── styles.css                   # Application styles
├── index.html                       # Main HTML
├── package.json
├── Gemfile
└── vite.config.ts
```

## Validation Rules Usage

In your HTML, add validation rules using the `data-rules` attribute:

```html
<!-- Single rule -->
<input
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField"
  data-rules="required"
/>

<!-- Multiple rules (pipe-separated) -->
<input
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField"
  data-rules="required|minLength:3|maxLength:50"
/>

<!-- With parameter -->
<input
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField"
  data-rules="required|minLength:8|password"
  type="password"
/>

<!-- Field matching -->
<input
  name="password"
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField"
  data-rules="required|minLength:8"
  type="password"
/>
<input
  name="confirmPassword"
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField"
  data-rules="required|matches:password"
  type="password"
/>

<!-- Async validation -->
<input
  data-form-validation-target="field"
  data-action="blur->form-validation#validateField input->form-validation#clearError"
  data-rules="required|email|asyncEmailCheck"
  type="email"
/>
```

## Available Validation Rules

| Rule | Parameters | Description | Example |
|------|-----------|-------------|---------|
| `required` | None | Field must not be empty | `data-rules="required"` |
| `minLength` | min | Minimum character length | `data-rules="minLength:3"` |
| `maxLength` | max | Maximum character length | `data-rules="maxLength:50"` |
| `email` | None | Valid email format | `data-rules="email"` |
| `alphanumeric` | None | Only letters and numbers | `data-rules="alphanumeric"` |
| `numeric` | None | Numbers only | `data-rules="numeric"` |
| `min` | minValue | Minimum numeric value | `data-rules="min:18"` |
| `max` | maxValue | Maximum numeric value | `data-rules="max:120"` |
| `password` | None | Strong password (uppercase, lowercase, number) | `data-rules="password"` |
| `phone` | None | Valid phone number | `data-rules="phone"` |
| `url` | None | Valid URL | `data-rules="url"` |
| `matches` | fieldName | Match another field's value | `data-rules="matches:password"` |
| `asyncEmailCheck` | None | Async email availability check | `data-rules="asyncEmailCheck"` |

## Controller API

### Targets

- `field` - Form input elements to validate
- `error` - Error message display elements
- `submitBtn` - Submit button (disabled when form invalid)
- `status` - Form status message display
- `totalFields` - Display total number of fields
- `validFields` - Display number of valid fields
- `invalidFields` - Display number of invalid fields
- `formValid` - Display form validity status

### Actions

- `validateField(event)` - Validate a field on blur
- `clearError(event)` - Clear error on input
- `handleSubmit(event)` - Handle form submission
- `resetForm()` - Reset form and validation state

### Values

- `submitUrl` - URL to submit form data (optional)

## Customizing Validation

### Adding Custom Rules

Edit `app/opal/controllers/form_validation_controller.rb`:

```ruby
def connect
  `
    const ctrl = this;

    // Add custom rule
    ctrl.validationRules.customRule = function(value, param) {
      // Your validation logic
      return true; // or false
    };

    // Add custom error message
    ctrl.errorMessages.customRule = 'Your error message';
  `
end
```

### Customizing Error Messages

```ruby
ctrl.errorMessages.required = 'Please fill this field';
ctrl.errorMessages.email = 'Email format is invalid';
```

## Testing Async Validation

The email field has async validation enabled. Try entering:

- `test@example.com` - Will show "This email is already taken" (simulated)
- Any other email - Will pass validation

## Form Submission

The form submission is currently simulated. To connect to a real API:

1. Set the `data-form-validation-submit-url-value` attribute on the form
2. The controller will use this URL for submission
3. Form data is collected as JSON and can be sent via fetch/AJAX

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- ES6+ features required
- No IE11 support

## Key Learnings

This example demonstrates:

1. **Stimulus Controller Pattern**: Clean separation of concerns
2. **Opal Integration**: Writing Ruby code that compiles to JavaScript
3. **Real-time Validation**: Immediate user feedback
4. **Async Operations**: Handling asynchronous validation
5. **State Management**: Tracking validation state with Map
6. **Visual Feedback**: CSS classes for error/success states

## Related Examples

- [Practical App](../practical-app) - Todo list with localStorage
- [Chart App](../chart-app) - Data visualization with Chart.js
- [Stimulus App](../stimulus-app) - Basic Stimulus patterns

## License

MIT
