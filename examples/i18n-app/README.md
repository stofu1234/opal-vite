# i18n Example

A comprehensive internationalization (i18n) example built with Opal, Stimulus, and Vite, demonstrating multi-language support with dynamic switching, pluralization, and locale-specific formatting.

## Features

- **5 Languages Supported**: English, Japanese (日本語), Spanish (Español), French (Français), German (Deutsch)
- **Dynamic Language Switching**: Instant language changes without page reload
- **localStorage Persistence**: Language preference saved in browser
- **Pluralization**: Smart handling of singular/plural/zero forms
- **Number Formatting**: Locale-specific currency and number formatting using Intl API
- **Date/Time Formatting**: Locale-specific date and time formats
- **Form Localization**: Translated labels and placeholders
- **Clean Architecture**: Structured translation management

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

The app will be available at `http://localhost:3012`

## Project Structure

```
i18n-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # JavaScript entry point
│   ├── opal/
│   │   ├── application.rb           # Opal entry point
│   │   └── controllers/
│   │       └── i18n_controller.rb   # Main i18n controller
│   └── styles.css                   # Application styles
├── index.html                       # Main HTML
├── package.json
├── Gemfile
└── vite.config.ts
```

## Translation Structure

Translations are organized in the i18n controller:

```ruby
ctrl.translations = {
  en: {
    title: '🌍 Internationalization Example',
    welcomeMessage: 'Welcome to our app!',
    placeholders: {
      name: 'Enter your name',
      email: 'Enter your email'
    },
    plurals: {
      message: {
        zero: 'You have no new messages',
        one: 'You have 1 new message',
        other: 'You have {count} new messages'
      }
    }
  },
  ja: {
    title: '🌍 国際化の例',
    welcomeMessage: 'アプリへようこそ！',
    # ...
  }
  # ... other languages
}
```

## Key Features Explained

### 1. Dynamic Language Switching

Click any language button to instantly switch the entire UI:

```html
<button
  class="lang-btn"
  data-action="click->i18n#switchLanguage"
  data-locale="ja"
>
  🇯🇵 日本語
</button>
```

The controller updates all text content and saves the preference:

```ruby
def switch_language(event)
  `
    const locale = event.currentTarget.dataset.locale;
    ctrl.currentLocaleValue = locale;
    localStorage.setItem('preferredLocale', locale);
    ctrl.updateTranslations();
  `
end
```

### 2. Pluralization

Handles zero, singular, and plural forms correctly:

```ruby
def pluralize(forms, count)
  `
    let key = 'other';
    if (count === 0) key = 'zero';
    else if (count === 1) key = 'one';

    const template = forms[key] || forms.other;
    return template.replace('{count}', count);
  `
end
```

**Examples:**
- 0 items: "Out of stock" (English) / "在庫なし" (Japanese)
- 1 item: "1 item in stock" / "在庫1点"
- 5 items: "5 items in stock" / "在庫5点"

### 3. Currency Formatting

Uses JavaScript's Intl.NumberFormat API for locale-specific formatting:

```ruby
def format_currency(amount)
  `
    return new Intl.NumberFormat(ctrl.currentLocaleValue, {
      style: 'currency',
      currency: ctrl.currentLocaleValue === 'ja' ? 'JPY' : 'USD'
    }).format(amount);
  `
end
```

**Examples:**
- English: $1,299.99
- Japanese: ¥1,300
- Spanish: US$ 1.299,99
- French: 1 299,99 $US
- German: 1.299,99 $

### 4. Date/Time Formatting

Locale-aware date and time formatting:

```ruby
def format_date(date)
  `
    return new Intl.DateTimeFormat(ctrl.currentLocaleValue, {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(date);
  `
end

def format_time(time)
  `
    return new Intl.DateTimeFormat(ctrl.currentLocaleValue, {
      hour: 'numeric',
      minute: 'numeric',
      hour12: ctrl.currentLocaleValue === 'en'
    }).format(time);
  `
end
```

**Examples:**
- English: December 15, 2025 / 2:30 PM
- Japanese: 2025年12月15日 / 14:30
- Spanish: 15 de diciembre de 2025 / 14:30
- French: 15 décembre 2025 / 14:30
- German: 15. Dezember 2025 / 14:30

### 5. Persistent Preferences

Language selection is saved to localStorage:

```javascript
// Save on change
localStorage.setItem('preferredLocale', locale);

// Load on page load
const savedLocale = localStorage.getItem('preferredLocale');
if (savedLocale && ctrl.translations[savedLocale]) {
  ctrl.currentLocaleValue = savedLocale;
}
```

## Adding New Languages

To add a new language:

1. **Add translation object** in `i18n_controller.rb`:

```ruby
ctrl.translations = {
  # ... existing languages
  zh: {
    title: '🌍 国际化示例',
    subtitle: '使用 Stimulus + Opal 的多语言支持',
    welcomeTitle: '欢迎！',
    # ... all other translations
  }
}
```

2. **Add language button** in `index.html`:

```html
<button
  class="lang-btn"
  data-action="click->i18n#switchLanguage"
  data-locale="zh"
  data-i18n-target="langBtn"
>
  🇨🇳 中文
</button>
```

3. **Update currency mapping** if needed:

```ruby
currency: ctrl.getCurrencyForLocale(ctrl.currentLocaleValue)

ctrl.getCurrencyForLocale = function(locale) {
  const currencies = {
    en: 'USD',
    ja: 'JPY',
    zh: 'CNY',
    // ...
  };
  return currencies[locale] || 'USD';
};
```

## Translation Best Practices

### 1. Keep Keys Consistent

Use the same key structure across all locales:

```ruby
en: { welcomeTitle: 'Welcome!' }
ja: { welcomeTitle: 'ようこそ！' }
es: { welcomeTitle: '¡Bienvenido!' }
```

### 2. Handle Plurals Properly

Always provide zero, one, and other forms:

```ruby
plurals: {
  item: {
    zero: 'Out of stock',
    one: '1 item',
    other: '{count} items'
  }
}
```

### 3. Consider Text Length

Different languages have different text lengths. Test your UI with all languages:

- German words tend to be longer
- Japanese/Chinese are more compact
- Use flexible layouts and test overflow

### 4. Use Native Formatting

Don't hardcode date/number formats. Use Intl API:

```javascript
// ✅ Good
new Intl.DateTimeFormat(locale).format(date)

// ❌ Bad
`${month}/${day}/${year}`
```

### 5. Separate Content from Code

Keep all translatable text in the translations object, not in code:

```javascript
// ✅ Good
alert(successMessages[ctrl.currentLocaleValue]);

// ❌ Bad
alert('Success!');
```

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Intl API support required
- localStorage support required
- No IE11 support

## Performance Considerations

- Translations loaded once at initialization
- Language switching is instant (no network requests)
- localStorage access is minimal
- Intl API is used efficiently with try-catch fallbacks

## Testing Different Locales

```javascript
// In browser console
localStorage.setItem('preferredLocale', 'ja');
location.reload();
```

Or simply click the language buttons in the UI.

## Common Issues

### Language not switching?

Check browser console for errors. Ensure:
- Translation object has the locale
- All required keys are present
- No JavaScript errors in controller

### Formatting not working?

The Intl API has try-catch fallbacks. If formatting fails:
- Falls back to basic toString() methods
- Check browser compatibility
- Verify locale code is valid

### Missing translations?

If a key is missing, the UI will show undefined. Always:
- Keep all locale objects in sync
- Use the same key names across locales
- Test all languages before deploying

## Related Examples

- [Form Validation](../form-validation-app) - Real-time form validation
- [Practical App](../practical-app) - Todo list with localStorage
- [Chart App](../chart-app) - Data visualization

## License

MIT
