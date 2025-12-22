import { test, expect } from '@playwright/test';

test.describe('Vue App with Opal', () => {
  test.beforeEach(async ({ page }) => {
    // Clear localStorage before each test
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    // Wait for Vue apps to mount
    await page.waitForTimeout(1000);
  });

  test.describe('Counter Component', () => {
    test('should display initial count of 0', async ({ page }) => {
      const countDisplay = page.locator('.count-value');
      await expect(countDisplay).toHaveText('0');
    });

    test('should increment count when clicking +', async ({ page }) => {
      await page.click('.btn-increment');
      const countDisplay = page.locator('.count-value');
      await expect(countDisplay).toHaveText('1');
    });

    test('should decrement count when clicking -', async ({ page }) => {
      await page.click('.btn-decrement');
      const countDisplay = page.locator('.count-value');
      await expect(countDisplay).toHaveText('-1');
    });

    test('should reset count to 0', async ({ page }) => {
      await page.click('.btn-increment');
      await page.click('.btn-increment');
      await page.click('.btn-reset');
      const countDisplay = page.locator('.count-value');
      await expect(countDisplay).toHaveText('0');
    });

    test('should show computed doubled value', async ({ page }) => {
      await page.click('.btn-increment');
      await page.click('.btn-increment');
      // Check that "Double: 4" appears
      await expect(page.locator('.counter-info')).toContainText('Double: 4');
    });

    test('should show computed absolute value', async ({ page }) => {
      await page.click('.btn-decrement');
      await page.click('.btn-decrement');
      // Count is -2, absolute should be 2
      await expect(page.locator('.counter-info')).toContainText('Absolute: 2');
    });

    test('should show positive status for positive count', async ({ page }) => {
      await page.click('.btn-increment');
      await expect(page.locator('.status .positive')).toBeVisible();
    });

    test('should show negative status for negative count', async ({ page }) => {
      await page.click('.btn-decrement');
      await expect(page.locator('.status .negative')).toBeVisible();
    });

    test('should show zero status for zero count', async ({ page }) => {
      await expect(page.locator('.status .zero')).toBeVisible();
    });
  });

  test.describe('Todo Component', () => {
    test('should display empty todo list initially', async ({ page }) => {
      const todoItems = page.locator('#todo-app .todo-item');
      await expect(todoItems).toHaveCount(0);
    });

    test('should add a new todo', async ({ page }) => {
      await page.fill('#todo-app .todo-input input', 'Test todo item');
      await page.click('#todo-app .todo-input button');

      await expect(page.locator('#todo-app .todo-item')).toHaveCount(1);
      await expect(page.locator('#todo-app .todo-item')).toContainText('Test todo item');
    });

    test('should add multiple todos', async ({ page }) => {
      await page.fill('#todo-app .todo-input input', 'First todo');
      await page.click('#todo-app .todo-input button');

      await page.fill('#todo-app .todo-input input', 'Second todo');
      await page.click('#todo-app .todo-input button');

      await expect(page.locator('#todo-app .todo-item')).toHaveCount(2);
    });

    test('should clear input after adding todo', async ({ page }) => {
      await page.fill('#todo-app .todo-input input', 'Test todo');
      await page.click('#todo-app .todo-input button');

      const input = page.locator('#todo-app .todo-input input');
      await expect(input).toHaveValue('');
    });

    test('should remove a todo', async ({ page }) => {
      await page.fill('#todo-app .todo-input input', 'Todo to remove');
      await page.click('#todo-app .todo-input button');

      await expect(page.locator('#todo-app .todo-item')).toHaveCount(1);

      await page.click('#todo-app .todo-item .delete-btn');
      await expect(page.locator('#todo-app .todo-item')).toHaveCount(0);
    });

    test('should show remaining count', async ({ page }) => {
      await page.fill('#todo-app .todo-input input', 'Todo 1');
      await page.click('#todo-app .todo-input button');

      await page.fill('#todo-app .todo-input input', 'Todo 2');
      await page.click('#todo-app .todo-input button');

      await expect(page.locator('#todo-app')).toContainText('2 item');
    });
  });
});
