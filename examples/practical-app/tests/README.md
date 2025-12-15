# Practical App E2E Tests

This directory contains end-to-end tests for the Practical App example using Playwright.

## Prerequisites

- Node.js 18 or higher
- pnpm (or npm/yarn)

## Installation

```bash
# Install dependencies
pnpm install

# Install Playwright browsers
pnpm exec playwright install chromium
```

## Running Tests

### Run all tests

```bash
pnpm test
```

### Run tests in UI mode (interactive)

```bash
pnpm test:ui
```

### Run tests in headed mode (see browser)

```bash
pnpm test:headed
```

### Run tests in debug mode

```bash
pnpm test:debug
```

### Run specific test file

```bash
pnpm exec playwright test tests/e2e/todo.spec.ts
```

### Run tests in a specific browser

```bash
pnpm exec playwright test --project=chromium
```

## Test Structure

```
tests/
├── e2e/
│   ├── todo.spec.ts      # Todo functionality tests
│   ├── theme.spec.ts     # Dark mode toggle tests
│   └── modal.spec.ts     # Modal interaction tests
└── README.md
```

## Test Coverage

### Todo Tests (`todo.spec.ts`)
- ✅ Add new todo
- ✅ Toggle todo completion
- ✅ Delete todo
- ✅ Filter todos (All/Active/Completed)
- ✅ Persist todos in localStorage
- ✅ Update todo count
- ✅ Validate input (no empty todos)
- ✅ Clear completed todos

### Theme Tests (`theme.spec.ts`)
- ✅ Toggle between light and dark mode
- ✅ Persist theme preference
- ✅ Update toggle button appearance
- ✅ Apply theme styles correctly
- ✅ Handle system preference

### Modal Tests (`modal.spec.ts`)
- ✅ Open modal
- ✅ Close modal with close button
- ✅ Close modal with backdrop click
- ✅ Close modal with Escape key
- ✅ Prevent body scroll when open
- ✅ Restore body scroll when closed
- ✅ Focus trap within modal
- ✅ Handle multiple modals

## Viewing Test Results

After running tests, you can view the HTML report:

```bash
pnpm exec playwright show-report
```

## Debugging Failed Tests

### Take screenshots

Screenshots are automatically taken on test failures and saved to `test-results/`.

### View trace

```bash
pnpm exec playwright show-trace test-results/[test-name]/trace.zip
```

### Run with headed browser

```bash
pnpm test:headed
```

### Use Playwright Inspector

```bash
pnpm test:debug
```

## Writing New Tests

1. Create a new test file in `tests/e2e/`
2. Import Playwright test utilities:
   ```typescript
   import { test, expect } from '@playwright/test';
   ```
3. Write your test:
   ```typescript
   test('my test', async ({ page }) => {
     await page.goto('/');
     // ... test code
   });
   ```

## Best Practices

1. **Use data attributes for selectors**
   ```typescript
   // Good
   await page.locator('[data-todo-target="input"]').fill('...');

   // Avoid
   await page.locator('.todo-input').fill('...');
   ```

2. **Wait for proper conditions**
   ```typescript
   // Good
   await expect(page.locator('.modal')).toBeVisible();

   // Avoid
   await page.waitForTimeout(1000);
   ```

3. **Clean up state**
   ```typescript
   test.beforeEach(async ({ page }) => {
     await page.evaluate(() => localStorage.clear());
   });
   ```

4. **Test user workflows**
   - Test complete user journeys, not just individual actions
   - Verify both UI changes and data persistence

5. **Keep tests independent**
   - Each test should work in isolation
   - Don't rely on execution order

## CI/CD Integration

These tests can be run in GitHub Actions or other CI systems. See the root-level `.github/workflows/test.yml` for an example configuration.

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Debugging Playwright Tests](https://playwright.dev/docs/debug)
