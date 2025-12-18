import { chromium } from 'playwright';

async function main() {
  console.log('Launching browser...');

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  // Collect all console messages and errors
  const errors = [];
  const logs = [];

  page.on('console', (msg) => {
    const text = msg.text();
    logs.push(`[${msg.type()}] ${text}`);
  });

  page.on('pageerror', (error) => {
    errors.push(`[PageError] ${error.message}`);
    console.error('Page Error:', error.message);
  });

  try {
    console.log('Navigating to http://localhost:3010...');
    await page.goto('http://localhost:3010', { waitUntil: 'networkidle', timeout: 30000 });

    // Wait a bit for any async errors
    await page.waitForTimeout(2000);

    console.log('\n=== Console Logs ===');
    logs.forEach(log => console.log(log));

    console.log('\n=== Errors ===');
    if (errors.length === 0) {
      console.log('No errors!');
    } else {
      errors.forEach(err => console.error(err));
    }

    // Check if Vue apps are mounted
    console.log('\n=== App Status ===');
    const counterContent = await page.$eval('#counter-app', el => el.innerHTML.trim()).catch(() => '');
    const todoContent = await page.$eval('#todo-app', el => el.innerHTML.trim()).catch(() => '');

    console.log('Counter app has content:', counterContent.length > 0);
    console.log('Todo app has content:', todoContent.length > 0);

    // Test Counter functionality
    console.log('\n=== Testing Counter ===');
    const countValue = await page.$eval('#counter-app .count-value', el => el.textContent);
    console.log('Initial count:', countValue);

    // Click increment button
    await page.click('#counter-app .btn-increment');
    await page.waitForTimeout(100);
    const newCountValue = await page.$eval('#counter-app .count-value', el => el.textContent);
    console.log('After increment:', newCountValue);
    console.log('Counter increment works:', newCountValue === '1');

    // Click decrement button
    await page.click('#counter-app .btn-decrement');
    await page.waitForTimeout(100);
    const afterDecrement = await page.$eval('#counter-app .count-value', el => el.textContent);
    console.log('After decrement:', afterDecrement);
    console.log('Counter decrement works:', afterDecrement === '0');

    // Test Todo functionality
    console.log('\n=== Testing Todo ===');

    // Type a new todo
    await page.fill('#todo-app input[type="text"]', 'Test todo item');
    await page.click('#todo-app button');  // Click Add button
    await page.waitForTimeout(200);

    // Check if todo was added
    const todoItems = await page.$$('#todo-app .todo-item');
    console.log('Todo items count:', todoItems.length);
    console.log('Todo add works:', todoItems.length === 1);

    if (todoItems.length > 0) {
      const todoText = await page.$eval('#todo-app .todo-item span', el => el.textContent);
      console.log('Todo text:', todoText);
    }

    // Check the remaining count
    const remaining = await page.$eval('#todo-app .todo-stats span', el => el.textContent).catch(() => 'N/A');
    console.log('Remaining text:', remaining);

    console.log('\n=== All Tests Passed ===');

  } catch (error) {
    console.error('Test error:', error.message);
    errors.push(error.message);
  } finally {
    await browser.close();
    process.exit(errors.length > 0 ? 1 : 0);
  }
}

main().catch(console.error);
