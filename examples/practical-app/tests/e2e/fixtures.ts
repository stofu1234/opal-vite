import { test as base, expect } from '@playwright/test';

// Extend base test to add automatic console error checking
export const test = base.extend<{
  autoCheckConsoleErrors: void;
}>({
  // This fixture automatically checks for console errors
  // It's set to auto: true so it runs for every test
  autoCheckConsoleErrors: [async ({ page }, use) => {
    const errors: string[] = [];

    // Capture page errors (uncaught exceptions)
    page.on('pageerror', (error) => {
      errors.push(`[PageError] ${error.message}`);
    });

    // Capture console.error messages
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        // Ignore some known non-critical errors
        const text = msg.text();
        if (text.includes('favicon.ico') || text.includes('404')) {
          return;
        }
        errors.push(`[ConsoleError] ${text}`);
      }
    });

    // Run the test
    await use();

    // After each test, fail if there were any errors
    if (errors.length > 0) {
      throw new Error(`JavaScript errors detected:\n${errors.join('\n')}`);
    }
  }, { auto: true }],
});

export { expect };
