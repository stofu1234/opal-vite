import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const logs = [];
  const errors = [];

  page.on('console', msg => {
    const text = msg.text();
    const type = msg.type();
    logs.push({ type, text });
    console.log(`[${type.toUpperCase()}] ${text}`);
  });

  page.on('pageerror', error => {
    errors.push(error.message);
    console.error(`[ERROR] ${error.message}`);
  });

  try {
    console.log('Loading page...');
    await page.goto('http://localhost:3012', {
      waitUntil: 'networkidle',
      timeout: 10000
    });

    console.log('\n=== Page loaded ===');

    // Wait a bit for any async initialization
    await page.waitForTimeout(2000);

    // Check if controller is connected
    const controllerConnected = await page.evaluate(() => {
      const form = document.querySelector('[data-controller="form-validation"]');
      return form !== null;
    });

    console.log(`Controller element found: ${controllerConnected}`);

    // Try to interact with a field
    try {
      await page.fill('input[name="username"]', 'test');
      console.log('Successfully filled username field');

      await page.click('input[name="email"]'); // blur the username field
      await page.waitForTimeout(500);

      console.log('Triggered validation');
    } catch (e) {
      console.log('Could not interact with form:', e.message);
    }

    console.log(`\n=== Summary ===`);
    console.log(`Total errors: ${errors.length}`);
    if (errors.length > 0) {
      console.log('Errors:');
      errors.forEach(err => console.log('  -', err));
      process.exit(1);
    } else {
      console.log('✅ No errors found!');
      process.exit(0);
    }

  } catch (error) {
    console.error('Test failed:', error.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
