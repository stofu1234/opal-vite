# Testing Guide for Opal-Vite Applications

This guide explains how to test Opal-Vite applications, including Stimulus controllers, Opal/Ruby code, and end-to-end testing.

## Table of Contents

- [Overview](#overview)
- [E2E Testing with Playwright](#e2e-testing-with-playwright)
- [Testing Stimulus Controllers](#testing-stimulus-controllers)
- [Testing Opal/Ruby Code](#testing-opalruby-code)
- [CI/CD Integration](#cicd-integration)
- [Best Practices](#best-practices)

## Overview

Opal-Vite applications can be tested at multiple levels:

1. **E2E Tests** - Test the entire application in a real browser
2. **Integration Tests** - Test Stimulus controllers and their interactions
3. **Unit Tests** - Test individual Opal/Ruby modules

### Recommended Testing Stack

- **E2E Testing**: [Playwright](https://playwright.dev/) - Fast, reliable browser automation
- **Unit/Integration Testing**: [Vitest](https://vitest.dev/) - Fast Vite-native test framework
- **Assertions**: Built-in expect API from Vitest/Playwright

## E2E Testing with Playwright

### Installation

```bash
# Install Playwright
pnpm add -D playwright @playwright/test

# Install browsers
pnpm exec playwright install chromium
```

### Basic E2E Test Example

Create `tests/e2e/basic.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Counter App', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000/');
  });

  test('should increment counter', async ({ page }) => {
    // Check initial state
    const counter = page.locator('[data-counter-target="count"]');
    await expect(counter).toHaveText('0');

    // Click increment button
    await page.click('button:has-text("Increment")');

    // Verify counter incremented
    await expect(counter).toHaveText('1');
  });

  test('should decrement counter', async ({ page }) => {
    // Set initial value
    await page.click('button:has-text("Increment")');
    await page.click('button:has-text("Increment")');

    // Decrement
    await page.click('button:has-text("Decrement")');

    // Verify result
    const counter = page.locator('[data-counter-target="count"]');
    await expect(counter).toHaveText('1');
  });
});
```

### Testing Chart.js Integration

Example from chart-app:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Chart App', () => {
  test('should render all charts', async ({ page }) => {
    await page.goto('http://localhost:3008/');

    // Wait for charts to initialize
    await page.waitForTimeout(2000);

    // Check canvas elements exist
    const canvases = await page.locator('canvas').count();
    expect(canvases).toBe(4);

    // Verify Chart.js instances were created
    const hasCharts = await page.evaluate(() => {
      const canvases = document.querySelectorAll('canvas');
      return Array.from(canvases).every(canvas => {
        // Check if canvas has a chart instance
        return canvas.width > 300; // Default is 300, charts should be larger
      });
    });

    expect(hasCharts).toBe(true);
  });

  test('should update chart on button click', async ({ page }) => {
    await page.goto('http://localhost:3008/');

    // Click randomize button
    await page.click('button:has-text("Randomize")');

    // Verify no errors occurred
    const errors = [];
    page.on('pageerror', error => errors.push(error));

    await page.waitForTimeout(500);
    expect(errors).toHaveLength(0);
  });
});
```

### Testing WebSocket Applications

Example from chat-app:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Chat App', () => {
  test('should connect to WebSocket server', async ({ page }) => {
    // Listen for console messages
    const messages = [];
    page.on('console', msg => messages.push(msg.text()));

    await page.goto('http://localhost:3007/');
    await page.waitForTimeout(1000);

    // Verify WebSocket connection
    const connected = messages.some(msg =>
      msg.includes('Connected to WebSocket')
    );
    expect(connected).toBe(true);
  });

  test('should send and receive messages', async ({ context }) => {
    // Create two pages (two users)
    const page1 = await context.newPage();
    const page2 = await context.newPage();

    await page1.goto('http://localhost:3007/');
    await page2.goto('http://localhost:3007/');

    // Wait for connection
    await page1.waitForTimeout(1000);

    // User 1 sends message
    await page1.fill('[data-chat-target="input"]', 'Hello from User 1');
    await page1.click('button:has-text("Send")');

    // User 2 should receive the message
    await page2.waitForSelector('text=Hello from User 1');

    const messageExists = await page2.locator('text=Hello from User 1').isVisible();
    expect(messageExists).toBe(true);
  });
});
```

### Playwright Configuration

Create `playwright.config.ts`:

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  webServer: {
    command: 'pnpm dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

## Testing Stimulus Controllers

### Manual Testing in Browser Console

You can test controllers directly in the browser:

```javascript
// Get controller instance
const element = document.querySelector('[data-controller="counter"]');
const app = window.Stimulus || window.application;
const controller = app.getControllerForElementAndIdentifier(element, 'counter');

// Call methods
controller.increment();

// Check values
console.log(controller.countValue); // Should be 1

// Verify targets
console.log(controller.hasCountTarget); // true
console.log(controller.countTarget.textContent); // "1"
```

### Integration Testing with Vitest

Create `tests/integration/counter.test.ts`:

```typescript
import { expect, test, beforeEach, afterEach } from 'vitest';
import { Application } from '@hotwired/stimulus';

test.describe('Counter Controller', () => {
  let application: Application;
  let container: HTMLDivElement;

  beforeEach(() => {
    // Setup DOM
    container = document.createElement('div');
    container.innerHTML = `
      <div data-controller="counter" data-counter-count-value="0">
        <div data-counter-target="count">0</div>
        <button data-action="click->counter#increment">+</button>
        <button data-action="click->counter#decrement">-</button>
      </div>
    `;
    document.body.appendChild(container);

    // Start Stimulus
    application = Application.start();

    // Register controller (you'll need to import your compiled Opal controller)
    // application.register('counter', CounterController);
  });

  afterEach(() => {
    application.stop();
    document.body.removeChild(container);
  });

  test('increments count', () => {
    const button = container.querySelector('button:first-of-type');
    const countEl = container.querySelector('[data-counter-target="count"]');

    button?.click();

    expect(countEl?.textContent).toBe('1');
  });

  test('decrements count', () => {
    const incButton = container.querySelector('button:first-of-type');
    const decButton = container.querySelector('button:last-of-type');
    const countEl = container.querySelector('[data-counter-target="count"]');

    // Increment twice
    incButton?.click();
    incButton?.click();

    // Decrement once
    decButton?.click();

    expect(countEl?.textContent).toBe('1');
  });
});
```

## Testing Opal/Ruby Code

### Unit Testing Opal Modules

While Opal code compiles to JavaScript, you can test the compiled output:

```ruby
# app/opal/utils/calculator.rb
module Calculator
  def self.add(a, b)
    a + b
  end

  def self.multiply(a, b)
    a * b
  end
end
```

Test the compiled JavaScript:

```typescript
// tests/unit/calculator.test.ts
import { expect, test } from 'vitest';

test.describe('Calculator', () => {
  test('adds two numbers', () => {
    // After Opal compilation, this would be available as:
    // expect(Opal.Calculator.$add(2, 3)).toBe(5);

    // For now, test the JavaScript output directly
    const add = (a: number, b: number) => a + b;
    expect(add(2, 3)).toBe(5);
  });
});
```

### Testing with Opal Runtime

You can load the Opal runtime in tests:

```typescript
import { expect, test, beforeAll } from 'vitest';

let Opal: any;

beforeAll(async () => {
  // Load Opal runtime
  const opalRuntime = await import('@opal-runtime');
  Opal = opalRuntime.default;

  // Load your compiled Opal code
  // This requires proper build setup
});

test('Calculator.add', () => {
  const result = Opal.Calculator.$add(2, 3);
  expect(result).toBe(5);
});
```

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install dependencies
        run: pnpm install

      - name: Run E2E tests
        run: pnpm test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

## Best Practices

### 1. Test Organization

```
your-app/
├── tests/
│   ├── e2e/
│   │   ├── counter.spec.ts
│   │   ├── todo.spec.ts
│   │   └── chat.spec.ts
│   ├── integration/
│   │   └── controllers.test.ts
│   └── unit/
│       └── utils.test.ts
├── playwright.config.ts
└── vitest.config.ts
```

### 2. Use Data Attributes for Testing

```html
<!-- Good: Use data-testid -->
<button data-testid="submit-button" data-action="click->form#submit">
  Submit
</button>

<!-- Also Good: Use Stimulus attributes -->
<button data-action="click->form#submit">Submit</button>
```

```typescript
// In tests
await page.click('[data-testid="submit-button"]');
// or
await page.click('[data-action*="form#submit"]');
```

### 3. Wait for Dynamic Content

```typescript
// Bad: Fixed timeout
await page.waitForTimeout(3000);

// Good: Wait for specific condition
await page.waitForSelector('[data-counter-target="count"]');
await page.waitForFunction(() =>
  document.querySelector('canvas')?.width > 300
);
```

### 4. Clean Up Resources

```typescript
test.afterEach(async ({ page }) => {
  // Close WebSocket connections
  await page.evaluate(() => {
    if (window.ws) {
      window.ws.close();
    }
  });

  // Destroy Chart.js instances
  await page.evaluate(() => {
    document.querySelectorAll('canvas').forEach(canvas => {
      const chart = (canvas as any).chart;
      if (chart) chart.destroy();
    });
  });
});
```

### 5. Test Error Handling

```typescript
test('handles network errors gracefully', async ({ page }) => {
  // Simulate offline
  await page.context().setOffline(true);

  await page.goto('http://localhost:3000/');

  // Should show error message
  await expect(page.locator('.error-message')).toBeVisible();
});
```

### 6. Parallel Test Execution

```typescript
// playwright.config.ts
export default defineConfig({
  fullyParallel: true,
  workers: process.env.CI ? 1 : undefined,
});
```

### 7. Visual Regression Testing

```typescript
test('matches screenshot', async ({ page }) => {
  await page.goto('http://localhost:3000/');
  await page.waitForLoadState('networkidle');

  await expect(page).toHaveScreenshot('homepage.png');
});
```

## Common Testing Scenarios

### Testing Form Submission

```typescript
test('submits form data', async ({ page }) => {
  await page.goto('http://localhost:3000/');

  await page.fill('[data-form-target="name"]', 'John Doe');
  await page.fill('[data-form-target="email"]', 'john@example.com');

  await page.click('button[type="submit"]');

  await expect(page.locator('.success-message')).toBeVisible();
});
```

### Testing Modal Interactions

```typescript
test('opens and closes modal', async ({ page }) => {
  await page.goto('http://localhost:3000/');

  // Open modal
  await page.click('[data-action="click->modal#open"]');
  await expect(page.locator('[data-modal-target="container"]')).toBeVisible();

  // Close modal
  await page.click('[data-action="click->modal#close"]');
  await expect(page.locator('[data-modal-target="container"]')).not.toBeVisible();
});
```

### Testing Dark Mode Toggle

```typescript
test('toggles dark mode', async ({ page }) => {
  await page.goto('http://localhost:3000/');

  const html = page.locator('html');

  // Initial state (light mode)
  await expect(html).not.toHaveClass(/dark/);

  // Toggle to dark mode
  await page.click('[data-action="click->theme#toggle"]');
  await expect(html).toHaveClass(/dark/);

  // Verify persistence (reload page)
  await page.reload();
  await expect(html).toHaveClass(/dark/);
});
```

## Debugging Tests

### 1. Run Tests in Headed Mode

```bash
# Playwright
pnpm exec playwright test --headed

# With debugging
pnpm exec playwright test --debug
```

### 2. Use Console Logs

```typescript
test('debug test', async ({ page }) => {
  page.on('console', msg => console.log('Browser:', msg.text()));
  page.on('pageerror', error => console.error('Error:', error));

  await page.goto('http://localhost:3000/');
});
```

### 3. Take Screenshots

```typescript
test('debug with screenshot', async ({ page }) => {
  await page.goto('http://localhost:3000/');
  await page.screenshot({ path: 'debug.png', fullPage: true });
});
```

### 4. Inspect Element State

```typescript
test('inspect state', async ({ page }) => {
  const state = await page.evaluate(() => {
    const el = document.querySelector('[data-controller="counter"]');
    return {
      controller: el?.getAttribute('data-controller'),
      targets: el?.querySelectorAll('[data-counter-target]').length,
      value: el?.getAttribute('data-counter-count-value')
    };
  });

  console.log('Element state:', state);
});
```

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [Stimulus Testing Patterns](https://stimulus.hotwired.dev/handbook/testing)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

## Next Steps

1. Add tests to your application
2. Set up CI/CD pipeline
3. Add visual regression tests
4. Configure code coverage reporting
5. Add performance testing

For example implementations, see:
- `examples/chart-app` - E2E testing with Playwright
- `examples/practical-app` - Integration testing examples
- `packages/vite-plugin-opal/test` - Unit testing examples
