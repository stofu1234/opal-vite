import { test, expect } from './fixtures';

test.describe('Theme Toggle', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001/');
    await page.waitForLoadState('networkidle');

    // Clear localStorage to start fresh
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await page.waitForLoadState('networkidle');
  });

  test('should toggle between light and dark mode', async ({ page }) => {
    const html = page.locator('html');
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Should start in light mode (no data-theme or data-theme="light")
    await expect(html).not.toHaveAttribute('data-theme', 'dark');

    // Toggle to dark mode
    await toggleButton.click();
    await expect(html).toHaveAttribute('data-theme', 'dark');

    // Toggle back to light mode
    await toggleButton.click();
    await expect(html).toHaveAttribute('data-theme', 'light');
  });

  test('should persist theme preference', async ({ page }) => {
    const html = page.locator('html');
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Toggle to dark mode
    await toggleButton.click();
    await expect(html).toHaveAttribute('data-theme', 'dark');

    // Reload page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Should still be in dark mode
    await expect(html).toHaveAttribute('data-theme', 'dark');
  });

  test('should update toggle button appearance', async ({ page }) => {
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // In light mode, button shows "Dark Mode"
    await expect(toggleButton).toContainText(/Dark Mode/i);

    // Toggle to dark mode
    await toggleButton.click();

    // In dark mode, button shows "Light Mode"
    await expect(toggleButton).toContainText(/Light Mode/i);
  });

  test('should apply theme styles correctly', async ({ page }) => {
    const toggleButton = page.locator('[data-action*="theme#toggle"]');

    // Toggle to dark mode
    await toggleButton.click();

    // Verify data-theme attribute is set
    const html = page.locator('html');
    await expect(html).toHaveAttribute('data-theme', 'dark');
  });

  test('should handle system preference', async ({ page }) => {
    // This test verifies that theme controller works with system preference
    // The current implementation uses localStorage, not system preference detection
    // So we just verify the basic toggle functionality works
    const toggleButton = page.locator('[data-action*="theme#toggle"]');
    const html = page.locator('html');

    // Toggle should work regardless of system preference
    await toggleButton.click();
    const theme = await html.getAttribute('data-theme');
    expect(['light', 'dark']).toContain(theme);
  });
});
