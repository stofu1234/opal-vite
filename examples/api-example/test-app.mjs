#!/usr/bin/env node
import { chromium } from 'playwright'
import { spawn } from 'child_process'

const PORT = 3004
const URL = `http://localhost:${PORT}`
const TEST_TIMEOUT = 30000 // 30 seconds

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
}

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`)
}

function logSuccess(message) {
  log(`✓ ${message}`, 'green')
}

function logError(message) {
  log(`✗ ${message}`, 'red')
}

function logInfo(message) {
  log(`ℹ ${message}`, 'cyan')
}

async function startDevServer() {
  logInfo('Starting dev server...')

  return new Promise((resolve, reject) => {
    const server = spawn('pnpm', ['dev'], {
      stdio: ['ignore', 'pipe', 'pipe']
    })

    let output = ''

    server.stdout.on('data', (data) => {
      output += data.toString()
      if (output.includes('Local:')) {
        logSuccess('Dev server started')
        resolve(server)
      }
    })

    server.stderr.on('data', (data) => {
      output += data.toString()
      if (output.includes('Local:')) {
        logSuccess('Dev server started')
        resolve(server)
      }
    })

    server.on('error', (err) => {
      reject(new Error(`Failed to start server: ${err.message}`))
    })

    // Timeout after 10 seconds
    setTimeout(() => {
      if (output.includes('Local:')) {
        resolve(server)
      } else {
        reject(new Error('Server did not start within 10 seconds'))
      }
    }, 10000)
  })
}

async function runTests() {
  let server = null
  let browser = null
  let exitCode = 0

  try {
    // Start dev server
    server = await startDevServer()

    // Wait a bit for server to be fully ready
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Launch browser
    logInfo('Launching headless browser...')
    browser = await chromium.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    })
    logSuccess('Browser launched')

    const context = await browser.newContext()
    const page = await context.newPage()

    // Collect console messages and errors
    const consoleMessages = []
    const consoleErrors = []

    page.on('console', msg => {
      const text = msg.text()
      consoleMessages.push(text)

      if (msg.type() === 'error') {
        consoleErrors.push(text)
      }
    })

    page.on('pageerror', error => {
      consoleErrors.push(error.message)
    })

    // Test 1: Page loads
    logInfo('Test 1: Loading page...')
    try {
      await page.goto(URL, { waitUntil: 'networkidle', timeout: TEST_TIMEOUT })
      logSuccess('Page loaded successfully')
    } catch (error) {
      logError(`Failed to load page: ${error.message}`)
      exitCode = 1
      throw error
    }

    // Wait for initialization
    await page.waitForTimeout(1000)

    // Test 2: Check for console initialization messages
    logInfo('Test 2: Checking console messages...')
    const hasStimulus = consoleMessages.some(msg => msg.includes('Stimulus initialized'))
    const hasRuby = consoleMessages.some(msg => msg.includes('API Example started with Ruby controllers'))

    if (hasStimulus) {
      logSuccess('Stimulus initialized correctly')
    } else {
      logError('Stimulus initialization message not found')
      exitCode = 1
    }

    if (hasRuby) {
      logSuccess('Ruby controllers loaded correctly')
    } else {
      logError('Ruby controllers initialization message not found')
      exitCode = 1
    }

    // Test 3: Check for JavaScript errors
    logInfo('Test 3: Checking for JavaScript errors...')
    if (consoleErrors.length === 0) {
      logSuccess('No console errors detected')
    } else {
      logError(`Found ${consoleErrors.length} console error(s):`)
      consoleErrors.forEach(err => {
        console.log(`  ${colors.red}${err}${colors.reset}`)
      })
      exitCode = 1
    }

    // Test 4: Check for expected elements
    logInfo('Test 4: Checking page structure...')

    const header = await page.locator('h1').first()
    const headerText = await header.textContent()
    if (headerText && headerText.includes('API Integration Example')) {
      logSuccess('Header found: ' + headerText)
    } else {
      logError('Expected header not found')
      exitCode = 1
    }

    // Test 5: Check for users section
    logInfo('Test 5: Checking users section...')
    const usersSection = await page.locator('[data-controller="users"]')
    const usersSectionCount = await usersSection.count()
    if (usersSectionCount > 0) {
      logSuccess('Users section found')
    } else {
      logError('Users section not found')
      exitCode = 1
    }

    // Test 6: Wait for API data to load
    logInfo('Test 6: Waiting for API data...')
    try {
      // Wait for either user cards or error message
      await page.waitForSelector('.user-card, .error-message', { timeout: 10000 })

      const userCards = await page.locator('.user-card').count()
      const errorMessage = await page.locator('.error-message[style*="display: block"]').count()

      if (userCards > 0) {
        logSuccess(`API data loaded: ${userCards} users found`)

        // Test 7: Test modal functionality
        logInfo('Test 7: Testing modal functionality...')
        const firstCard = page.locator('.user-card').first()
        await firstCard.click()

        // Wait for modal to appear
        await page.waitForSelector('.modal.active', { timeout: 5000 })
        const modalActive = await page.locator('.modal.active').count()

        if (modalActive > 0) {
          logSuccess('Modal opened successfully')

          // Check for user details
          const userName = await page.locator('[data-user-modal-target="userName"]').textContent()
          if (userName) {
            logSuccess(`User details loaded: ${userName}`)
          } else {
            logError('User details not found in modal')
            exitCode = 1
          }
        } else {
          logError('Modal did not open')
          exitCode = 1
        }
      } else if (errorMessage > 0) {
        logError('API request failed - error message displayed')
        exitCode = 1
      } else {
        logError('Neither user cards nor error message found')
        exitCode = 1
      }
    } catch (error) {
      logError(`Failed to load API data: ${error.message}`)
      exitCode = 1
    }

    // Summary
    console.log('')
    log('═══════════════════════════════════════', 'blue')
    if (exitCode === 0) {
      log('All tests passed! ✓', 'green')
    } else {
      log('Some tests failed. ✗', 'red')
    }
    log('═══════════════════════════════════════', 'blue')

  } catch (error) {
    logError(`Test error: ${error.message}`)
    exitCode = 1
  } finally {
    // Cleanup
    if (browser) {
      logInfo('Closing browser...')
      await browser.close()
    }

    if (server) {
      logInfo('Stopping dev server...')
      server.kill()
    }

    process.exit(exitCode)
  }
}

// Run tests
runTests()
