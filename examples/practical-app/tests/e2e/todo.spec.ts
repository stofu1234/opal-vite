import { test, expect } from './fixtures';

test.describe('Todo Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001/');
    await page.waitForLoadState('networkidle');
    // Clear localStorage to ensure clean state for each test
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    await page.waitForLoadState('networkidle');
  });

  test('should add a new todo', async ({ page }) => {
    const input = page.locator('[data-todo-target="input"]');
    const todoList = page.locator('[data-todo-target="list"]');

    // Add a new todo
    await input.fill('Buy groceries');
    await page.keyboard.press('Enter');

    // Verify todo was added
    await expect(todoList.locator('text=Buy groceries')).toBeVisible();

    // Input should be cleared
    await expect(input).toHaveValue('');
  });

  test('should toggle todo completion', async ({ page }) => {
    // Add a todo first
    await page.locator('[data-todo-target="input"]').fill('Test todo');
    await page.keyboard.press('Enter');

    // Find the checkbox and todo item
    const checkbox = page.locator('[data-todo-target="list"] input[type="checkbox"]').first();
    const todoItem = page.locator('[data-todo-target="list"] .todo-item').first();

    // Initially unchecked
    await expect(checkbox).not.toBeChecked();
    await expect(todoItem).not.toHaveClass(/completed/);

    // Toggle completion
    await checkbox.click();

    // Should be checked and styled (completed class adds line-through via CSS)
    await expect(checkbox).toBeChecked();
    await expect(todoItem).toHaveClass(/completed/);
  });

  test('should delete a todo', async ({ page }) => {
    // Add a todo
    await page.locator('[data-todo-target="input"]').fill('Todo to delete');
    await page.keyboard.press('Enter');

    // Verify it exists
    await expect(page.locator('text=Todo to delete')).toBeVisible();

    // Click delete button
    const deleteButton = page.locator('[data-todo-target="list"] button[data-action*="delete"]').first();
    await deleteButton.click();

    // Todo should be removed
    await expect(page.locator('text=Todo to delete')).not.toBeVisible();
  });

  test('should filter completed todos', async ({ page }) => {
    // Add multiple todos
    await page.locator('[data-todo-target="input"]').fill('Todo 1');
    await page.keyboard.press('Enter');

    await page.locator('[data-todo-target="input"]').fill('Todo 2');
    await page.keyboard.press('Enter');

    // Complete first todo
    await page.locator('[data-todo-target="list"] input[type="checkbox"]').first().click();

    // Click "Completed" filter button (using specific selector to avoid matching count text)
    await page.click('button[data-filter="completed"]');

    // Should show only completed todo
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 1')).toBeVisible();
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 2')).not.toBeVisible();

    // Click "Active" filter button
    await page.click('button[data-filter="active"]');

    // Should show only active todo
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 1')).not.toBeVisible();
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 2')).toBeVisible();

    // Click "All" filter button
    await page.click('button[data-filter="all"]');

    // Should show both
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 1')).toBeVisible();
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 2')).toBeVisible();
  });

  test('should persist todos in localStorage', async ({ page }) => {
    // Add a todo
    await page.locator('[data-todo-target="input"]').fill('Persistent todo');
    await page.keyboard.press('Enter');

    // Reload page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Todo should still be there
    await expect(page.locator('text=Persistent todo')).toBeVisible();
  });

  test('should show todo count', async ({ page }) => {
    // Check initial count
    const countElement = page.locator('[data-todo-target="count"]');

    // Add todos
    await page.locator('[data-todo-target="input"]').fill('Todo 1');
    await page.keyboard.press('Enter');

    await page.locator('[data-todo-target="input"]').fill('Todo 2');
    await page.keyboard.press('Enter');

    // Count should update
    await expect(countElement).toContainText('2');

    // Complete one todo
    await page.locator('[data-todo-target="list"] input[type="checkbox"]').first().click();

    // Active count should decrease
    await expect(countElement).toContainText('1');
  });

  test('should not add empty todos', async ({ page }) => {
    const input = page.locator('[data-todo-target="input"]');
    const todoList = page.locator('[data-todo-target="list"]');

    // Get initial todo count
    const initialCount = await todoList.locator('.todo-item').count();

    // Try to add empty todo
    await input.fill('   '); // Just spaces
    await page.keyboard.press('Enter');

    // Count should not change
    const finalCount = await todoList.locator('.todo-item').count();
    expect(finalCount).toBe(initialCount);
  });

  test('should clear completed todos', async ({ page }) => {
    // Add and complete multiple todos
    for (let i = 1; i <= 3; i++) {
      await page.locator('[data-todo-target="input"]').fill(`Todo ${i}`);
      await page.keyboard.press('Enter');
    }

    // Wait for all todos to be added
    await expect(page.locator('[data-todo-target="list"] .todo-item')).toHaveCount(3);

    // Complete first two
    const checkboxes = page.locator('[data-todo-target="list"] input[type="checkbox"]');
    await checkboxes.nth(0).click();
    await checkboxes.nth(1).click();

    // Click "Clear Completed" button (using specific selector)
    await page.click('button:has-text("Clear Completed")');

    // Only active todo should remain in the list
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 1')).not.toBeVisible();
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 2')).not.toBeVisible();
    await expect(page.locator('[data-todo-target="list"]').locator('text=Todo 3')).toBeVisible();
  });
});
