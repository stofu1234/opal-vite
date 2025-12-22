import { test, expect } from '@playwright/test';

test.describe('Snabberb App', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('page loads with correct title', async ({ page }) => {
    await expect(page).toHaveTitle(/Snabberb/);
  });

  test('Counter component renders and works', async ({ page }) => {
    // Wait for component to mount
    await page.waitForSelector('.count-value');

    // Check initial state
    const counterValue = page.locator('.count-value');
    await expect(counterValue).toHaveText('0');

    // Test increment
    await page.click('.btn-increment');
    await expect(counterValue).toHaveText('1');

    // Test increment again
    await page.click('.btn-increment');
    await expect(counterValue).toHaveText('2');

    // Test decrement
    await page.click('.btn-decrement');
    await expect(counterValue).toHaveText('1');

    // Test reset
    await page.click('.btn-reset');
    await expect(counterValue).toHaveText('0');

    // Test decrement to negative
    await page.click('.btn-decrement');
    await expect(counterValue).toHaveText('-1');

    // Check status display changes
    await expect(page.locator('.negative')).toBeVisible();
  });

  test('Todo component renders with empty state', async ({ page }) => {
    // Wait for component to mount
    await page.waitForSelector('.todo-input');

    // Check empty state message
    await expect(page.locator('.empty-state')).toContainText('No todos yet');
  });

  test('Todo component can add and manage todos', async ({ page }) => {
    // Wait for component
    await page.waitForSelector('.todo-input');

    // Add a todo
    const input = page.locator('.todo-input input[type="text"]');
    await input.fill('Buy groceries');
    await page.click('.todo-input button');

    // Verify todo was added
    await expect(page.locator('.todo-item')).toHaveCount(1);
    await expect(page.locator('.todo-item span')).toContainText('Buy groceries');

    // Check stats
    await expect(page.locator('.todo-stats')).toContainText('1 item left');

    // Add another todo
    await input.fill('Walk the dog');
    await input.press('Enter');

    await expect(page.locator('.todo-item')).toHaveCount(2);
    await expect(page.locator('.todo-stats')).toContainText('2 items left');

    // Complete a todo
    await page.locator('.todo-item').first().locator('input[type="checkbox"]').click();

    // Check completion
    await expect(page.locator('.todo-item.completed')).toHaveCount(1);
    await expect(page.locator('.todo-stats')).toContainText('1 item left');
    await expect(page.locator('.clear-completed')).toContainText('Clear completed (1)');

    // Delete a todo
    await page.locator('.todo-item').first().locator('.delete-btn').click();
    await expect(page.locator('.todo-item')).toHaveCount(1);

    // Clear completed
    await page.locator('.todo-item input[type="checkbox"]').click();
    await page.locator('.clear-completed').click();

    // Back to empty state
    await expect(page.locator('.empty-state')).toContainText('No todos yet');
  });

  test('Todo input clears after adding', async ({ page }) => {
    await page.waitForSelector('.todo-input');

    const input = page.locator('.todo-input input[type="text"]');
    await input.fill('Test todo');
    await page.click('.todo-input button');

    // Input should be cleared
    await expect(input).toHaveValue('');
  });

  test('empty todo cannot be added', async ({ page }) => {
    await page.waitForSelector('.todo-input');

    // Try to add empty todo
    await page.click('.todo-input button');

    // Should still show empty state
    await expect(page.locator('.empty-state')).toContainText('No todos yet');
  });
});
