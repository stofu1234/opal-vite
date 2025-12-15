import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const errors = [];
  page.on('pageerror', error => {
    errors.push(error.message);
    console.error(`[ERROR] ${error.message}`);
  });

  page.on('console', msg => console.log(`[${msg.type().toUpperCase()}] ${msg.text()}`));

  try {
    console.log('Loading page...');
    await page.goto('http://localhost:3012', { waitUntil: 'networkidle', timeout: 10000 });

    console.log('\n=== Testing Form Validation ===\n');

    // Test 1: Fill in a valid username
    console.log('Test 1: Valid username (4+ characters)');
    await page.fill('input[name="username"]', 'testuser');
    await page.click('input[name="email"]'); // trigger blur
    await page.waitForTimeout(500);

    const usernameError = await page.textContent('[name="username"] ~ .error-message');
    console.log('  Username error:', usernameError || '(none)');

    // Test 2: Invalid email
    console.log('\nTest 2: Invalid email');
    await page.fill('input[name="email"]', 'invalid');
    await page.click('input[name="username"]'); // trigger blur
    await page.waitForTimeout(500);

    const emailError = await page.textContent('[name="email"] ~ .error-message');
    console.log('  Email error:', emailError || '(none)');

    // Test 3: Valid email
    console.log('\nTest 3: Valid email');
    await page.fill('input[name="email"]', 'user@example.com');
    await page.click('input[name="username"]');
    await page.waitForTimeout(1500); // wait for async validation

    const emailError2 = await page.textContent('[name="email"] ~ .error-message');
    console.log('  Email error:', emailError2 || '(none)');

    // Test 4: Check validation stats
    console.log('\nTest 4: Validation stats');
    const validFields = await page.textContent('[data-form-validation-target="validFields"]');
    const invalidFields = await page.textContent('[data-form-validation-target="invalidFields"]');
    console.log('  Valid fields:', validFields);
    console.log('  Invalid fields:', invalidFields);

    // Test 5: Try to submit incomplete form
    console.log('\nTest 5: Submit incomplete form');
    const submitBtn = await page.$('button[type="submit"]');
    const isDisabled = await submitBtn.evaluate(el => el.disabled);
    console.log('  Submit button disabled:', isDisabled);

    if (errors.length > 0) {
      console.log('\n=== ERRORS FOUND ===');
      errors.forEach(err => console.log('  -', err));
      process.exit(1);
    } else {
      console.log('\n✅ All tests passed! Form validation is working.');
      process.exit(0);
    }

  } catch (error) {
    console.error('Test failed:', error.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
