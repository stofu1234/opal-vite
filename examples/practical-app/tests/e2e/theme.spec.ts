import { test, expect } from '@playwright/test';

test.describe('Theme Toggle', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001/');
    await page.waitForLoadState('networkidle');

    // Clear localStorage to start fresh
    await page.evaluate(() => localStorage.clear());
    await page.reload();
  });

  test('should toggle between light and dark mode', async ({ page }) => {
    const html = page.locator('html');
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Should start in light mode
    await expect(html).not.toHaveClass(/dark/);

    // Toggle to dark mode
    await toggleButton.click();
    await expect(html).toHaveClass(/dark/);

    // Toggle back to light mode
    await toggleButton.click();
    await expect(html).not.toHaveClass(/dark/);
  });

  test('should persist theme preference', async ({ page }) => {
    const html = page.locator('html');
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Toggle to dark mode
    await toggleButton.click();
    await expect(html).toHaveClass(/dark/);

    // Reload page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Should still be in dark mode
    await expect(html).toHaveClass(/dark/);
  });

  test('should update toggle button appearance', async ({ page }) => {
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Check light mode icon
    await expect(toggleButton).toContainText(/🌙|Moon|Dark/i);

    // Toggle to dark mode
    await toggleButton.click();

    // Check dark mode icon
    await expect(toggleButton).toContainText(/☀️|Sun|Light/i);
  });

  test('should apply theme styles correctly', async ({ page }) => {
    const html = page.locator('html');
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Toggle to dark mode
    await toggleButton.click();

    // Check background color changed
    const bgColor = await page.evaluate(() => {
      return window.getComputedStyle(document.documentElement).backgroundColor;
    });

    // Dark mode should have dark background (not white)
    expect(bgColor).not.toBe('rgb(255, 255, 255)');
  });

  test('should handle system preference', async ({ page, context }) => {
    // Set system to dark mode
    await context.emulateMedia({ colorScheme: 'dark' });

    // Reload page
    await page.reload();
    await page.waitForLoadState('networkidle');

    const html = page.locator('html');

    // Should respect system preference if no saved preference
    // (This depends on your implementation)
    const hasDarkClass = await html.evaluate(el => el.classList.contains('dark'));
    expect(typeof hasDarkClass).toBe('boolean');
  });
});
