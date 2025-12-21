# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'
require 'opal/vite/testing/stable_helpers'

# Find browser path (system Chrome, Playwright Chromium, or CI Chrome)
def find_browser_path
  paths = []

  # Environment variable (highest priority)
  paths << ENV['BROWSER_PATH'] if ENV['BROWSER_PATH']

  # GitHub Actions Chrome (browser-actions/setup-chrome)
  paths << ENV['CHROME_PATH'] if ENV['CHROME_PATH']

  # Common Chrome/Chromium locations
  paths += [
    '/usr/bin/google-chrome',
    '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium',
    '/usr/bin/chromium-browser'
  ]

  # Playwright-installed Chromium (fallback for local dev)
  playwright_browsers = Dir.glob(File.expand_path('~/.cache/ms-playwright/chromium-*/chrome-linux/chrome'))
  paths += playwright_browsers

  paths.compact.find { |path| File.exist?(path.to_s) }
end

# Configure Cuprite driver
Capybara.register_driver :cuprite do |app|
  browser_path = find_browser_path

  options = {
    window_size: [1280, 800],
    js_errors: true,           # Fail tests on JS errors
    headless: !ENV['HEADLESS'].nil? ? ENV['HEADLESS'] != 'false' : true,
    slowmo: ENV['SLOWMO']&.to_f,
    timeout: 10,
    process_timeout: 15,
    browser_options: { 'no-sandbox' => nil }
  }

  options[:browser_path] = browser_path if browser_path

  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

# Configure app host (Vite dev server)
Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3013')
Capybara.run_server = false  # Don't start a server, use external Vite dev server

# Default max wait time for async operations
# Increase to handle Opal compilation time
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  # Include Capybara DSL and StableHelpers
  config.include Capybara::DSL, type: :feature
  config.include StableHelpers, type: :feature

  # Reset state before each test
  config.before(:each, type: :feature) do
    # Clear localStorage
    visit '/'
    # Wait for Opal/Stimulus controllers to initialize
    wait_for_pwa_ready
    page.execute_script('localStorage.clear()')
    visit '/'
    # Wait for Opal/Stimulus to load again
    wait_for_pwa_ready
    # Wait for DOM to stabilize after Opal initialization
    wait_for_dom_stable
  end

  # Wait for PWA Stimulus controllers to be fully connected
  def wait_for_pwa_ready(timeout: 15)
    start_time = Time.now
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          // Check if Stimulus application exists
          if (typeof Stimulus === 'undefined') return false;

          // Check if pwa controller is connected
          var pwaEl = document.querySelector('[data-controller~="pwa"]');
          if (!pwaEl) return false;

          // Check if offline-detector controller is connected
          var offlineEl = document.querySelector('[data-controller~="offline-detector"]');
          if (!offlineEl) return false;

          // Check if status targets exist
          var statusText = document.querySelector('[data-offline-detector-target="statusText"]');
          var notesList = document.querySelector('[data-pwa-target="notesList"]');
          if (!statusText || !notesList) return false;

          return true;
        })()
      JS
      return if result

      elapsed = Time.now - start_time
      raise Capybara::ElementNotFound, "PWA controllers not ready within #{timeout}s" if elapsed > timeout

      sleep 0.1
    end
  end

  # Helper to add a note using native browser form submission
  def add_note(text)
    # Wait for Stimulus controller to be fully connected
    js_wait_for(<<~JS, timeout: 10)
      (function() {
        var el = document.querySelector('[data-controller~="pwa"]');
        if (!el || !window.Stimulus) return false;
        var ctrl = window.Stimulus.getControllerForElementAndIdentifier(el, 'pwa');
        return ctrl && (typeof ctrl.$add_note === 'function' || typeof ctrl.add_note === 'function');
      })()
    JS

    # Set input value using JavaScript
    escaped_text = text.gsub("'", "\\\\'")
    page.execute_script(<<~JS)
      (function() {
        var input = document.querySelector('[data-pwa-target="noteInput"]');
        input.value = '#{escaped_text}';
        input.dispatchEvent(new Event('input', { bubbles: true }));
      })()
    JS

    # Submit form using native button click
    stable_click('.btn-primary[type="submit"]')

    sleep 0.3
    wait_for_dom_stable
  end

  # Retry helper for flaky operations with browser reload
  def with_browser_retry(max_attempts: 5, &block)
    attempts = 0
    begin
      attempts += 1
      block.call
    rescue Capybara::ElementNotFound, Ferrum::TimeoutError, Timeout::Error => e
      if attempts < max_attempts
        warn "[Retry #{attempts}/#{max_attempts}] #{e.class}: #{e.message.lines.first.chomp}"
        # Reload browser and wait for pwa ready
        visit '/'
        wait_for_pwa_ready
        page.execute_script('localStorage.clear()')
        visit '/'
        wait_for_pwa_ready
        wait_for_dom_stable
        retry
      else
        raise
      end
    end
  end
end
