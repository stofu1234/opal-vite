import { test, expect } from './fixtures';

test.describe('Modal Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001/');
    await page.waitForLoadState('networkidle');

    // Clear localStorage to start fresh
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Add a todo so we can edit it to trigger the modal
    await page.locator('[data-todo-target="input"]').fill('Test todo for modal');
    await page.keyboard.press('Enter');
    await expect(page.locator('[data-todo-target="list"]').locator('text=Test todo for modal')).toBeVisible();
  });

  // Helper to open modal via edit button
  async function openModal(page: import('@playwright/test').Page) {
    const editButton = page.locator('[data-action*="todo#edit_todo"]').first();
    await editButton.click();
    // Wait for modal to become active
    await expect(page.locator('.modal.active')).toBeVisible();
  }

  test('should open modal', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Modal should be hidden initially (no active class)
    await expect(modal).not.toHaveClass(/active/);

    // Click edit button to open modal
    await openModal(page);

    // Modal should be visible (has active class)
    await expect(modal).toHaveClass(/active/);
  });

  test('should close modal with close button', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Open modal
    await openModal(page);
    await expect(modal).toHaveClass(/active/);

    // Click the X close button (use specific selector to avoid matching overlay)
    const closeButton = page.locator('button.modal-close');
    await closeButton.click();

    // Modal should be hidden
    await expect(modal).not.toHaveClass(/active/);
  });

  test('should close modal with Cancel button', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Open modal
    await openModal(page);
    await expect(modal).toHaveClass(/active/);

    // Click Cancel button (secondary close option)
    await page.locator('.modal button:has-text("Cancel")').click();

    // Modal should be hidden
    await expect(modal).not.toHaveClass(/active/);
  });

  test('should close modal with Escape key', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Open modal
    await openModal(page);
    await expect(modal).toHaveClass(/active/);

    // Press Escape
    await page.keyboard.press('Escape');

    // Modal should be hidden
    await expect(modal).not.toHaveClass(/active/);
  });

  test('should prevent body scroll when modal is open', async ({ page }) => {
    // Open modal
    await openModal(page);

    // Check if body has overflow hidden
    const bodyOverflow = await page.evaluate(() => {
      return window.getComputedStyle(document.body).overflow;
    });

    expect(bodyOverflow).toBe('hidden');
  });

  test('should restore body scroll when modal closes', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Open modal
    await openModal(page);

    // Close modal using the X button
    const closeButton = page.locator('button.modal-close');
    await closeButton.click();

    // Wait for modal to close
    await expect(modal).not.toHaveClass(/active/);

    // Body overflow should be restored
    const bodyOverflow = await page.evaluate(() => {
      return window.getComputedStyle(document.body).overflow;
    });

    expect(['visible', 'auto', '']).toContain(bodyOverflow);
  });

  test('should focus input within modal', async ({ page }) => {
    // Open modal
    await openModal(page);

    // Wait for focus to be set (modal uses setTimeout for focus)
    await page.waitForTimeout(200);

    // Focus should be on the input inside modal
    const focusedElement = await page.evaluate(() => {
      return document.activeElement?.closest('.modal[data-controller="modal"]') !== null;
    });

    expect(focusedElement).toBe(true);
  });

  test('should save changes when save button is clicked', async ({ page }) => {
    const modal = page.locator('.modal[data-controller="modal"]');

    // Open modal
    await openModal(page);

    // Change the todo text
    const modalInput = page.locator('[data-modal-target="input"]');
    await modalInput.clear();
    await modalInput.fill('Updated todo text');

    // Click save button
    await page.locator('.modal button:has-text("Save")').click();

    // Modal should close
    await expect(modal).not.toHaveClass(/active/);

    // Todo should be updated
    await expect(page.locator('[data-todo-target="list"]').locator('text=Updated todo text')).toBeVisible();
  });
});
