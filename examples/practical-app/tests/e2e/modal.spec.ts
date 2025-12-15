import { test, expect } from '@playwright/test';

test.describe('Modal Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001/');
    await page.waitForLoadState('networkidle');
  });

  test('should open modal', async ({ page }) => {
    const modal = page.locator('[data-modal-target="container"]');
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Modal should be hidden initially
    await expect(modal).not.toBeVisible();

    // Click open button
    await openButton.click();

    // Modal should be visible
    await expect(modal).toBeVisible();
  });

  test('should close modal with close button', async ({ page }) => {
    const modal = page.locator('[data-modal-target="container"]');
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Open modal
    await openButton.click();
    await expect(modal).toBeVisible();

    // Click close button
    const closeButton = page.locator('[data-action*="modal#close"]').first();
    await closeButton.click();

    // Modal should be hidden
    await expect(modal).not.toBeVisible();
  });

  test('should close modal with backdrop click', async ({ page }) => {
    const modal = page.locator('[data-modal-target="container"]');
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Open modal
    await openButton.click();
    await expect(modal).toBeVisible();

    // Click backdrop (outside modal content)
    await page.locator('[data-modal-target="backdrop"]').click();

    // Modal should be hidden
    await expect(modal).not.toBeVisible();
  });

  test('should close modal with Escape key', async ({ page }) => {
    const modal = page.locator('[data-modal-target="container"]');
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Open modal
    await openButton.click();
    await expect(modal).toBeVisible();

    // Press Escape
    await page.keyboard.press('Escape');

    // Modal should be hidden
    await expect(modal).not.toBeVisible();
  });

  test('should prevent body scroll when modal is open', async ({ page }) => {
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Open modal
    await openButton.click();

    // Check if body has overflow hidden
    const bodyOverflow = await page.evaluate(() => {
      return window.getComputedStyle(document.body).overflow;
    });

    expect(bodyOverflow).toBe('hidden');
  });

  test('should restore body scroll when modal closes', async ({ page }) => {
    const modal = page.locator('[data-modal-target="container"]');
    const openButton = page.locator('[data-action*="modal#open"]').first();
    const closeButton = page.locator('[data-action*="modal#close"]').first();

    // Open modal
    await openButton.click();

    // Close modal
    await closeButton.click();

    // Wait for animation
    await page.waitForTimeout(300);

    // Body overflow should be restored
    const bodyOverflow = await page.evaluate(() => {
      return window.getComputedStyle(document.body).overflow;
    });

    expect(['visible', 'auto', '']).toContain(bodyOverflow);
  });

  test('should focus trap within modal', async ({ page }) => {
    const openButton = page.locator('[data-action*="modal#open"]').first();

    // Open modal
    await openButton.click();

    // Tab through modal elements
    await page.keyboard.press('Tab');

    // Focus should be within modal
    const focusedElement = await page.evaluate(() => {
      return document.activeElement?.closest('[data-modal-target="container"]') !== null;
    });

    expect(focusedElement).toBe(true);
  });

  test('should handle multiple modals', async ({ page }) => {
    const modals = page.locator('[data-modal-target="container"]');

    // Check if multiple modals exist
    const modalCount = await modals.count();

    if (modalCount > 1) {
      // Open first modal
      await page.locator('[data-action*="modal#open"]').first().click();
      await expect(modals.first()).toBeVisible();

      // Other modals should remain hidden
      for (let i = 1; i < modalCount; i++) {
        await expect(modals.nth(i)).not.toBeVisible();
      }
    }
  });
});
