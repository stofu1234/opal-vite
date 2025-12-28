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
    timeout: 15,
    process_timeout: 30,
    browser_options: { 'no-sandbox' => nil }
  }

  options[:browser_path] = browser_path if browser_path

  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

# Configure app host (Vite dev server)
Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3007')
Capybara.run_server = false  # Don't start a server, use external Vite dev server

# Default max wait time for async operations
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
    visit '/'
    wait_for_stimulus_ready
    # Extra wait for DOM to stabilize
    sleep 0.5
  end

  # Wait for Stimulus controllers to be fully connected
  def wait_for_stimulus_ready(timeout: 15)
    start_time = Time.now
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          // Check if Stimulus application exists
          if (typeof Stimulus === 'undefined') return false;

          // Check if tabs controller is connected
          var tabsEl = document.querySelector('[data-controller~="tabs"]');
          if (!tabsEl) return false;

          // Check if panel controllers are connected
          var panels = document.querySelectorAll('[data-controller~="panel"]');
          if (panels.length !== 4) return false;

          // Check if first panel is visible
          var firstPanel = panels[0];
          if (!firstPanel.classList.contains('panel-visible')) return false;

          return true;
        })()
      JS
      return if result

      elapsed = Time.now - start_time
      raise Capybara::ElementNotFound, "Stimulus controllers not ready within #{timeout}s" if elapsed > timeout

      sleep 0.1
    end
  end

  # Check for JavaScript errors in console
  def check_js_errors
    errors = page.driver.browser.evaluate(<<~JS)
      window.__jsErrors || []
    JS
    raise "JavaScript errors detected: #{errors.join(', ')}" if errors.any?
  end

  # Retry helper for flaky operations
  def with_browser_retry(max_attempts: 3, &block)
    attempts = 0
    begin
      attempts += 1
      block.call
    rescue Capybara::ElementNotFound, Ferrum::TimeoutError, Timeout::Error => e
      if attempts < max_attempts
        warn "[Retry #{attempts}/#{max_attempts}] #{e.class}: #{e.message.lines.first.chomp}"
        visit '/'
        wait_for_stimulus_ready
        retry
      else
        raise
      end
    end
  end
end
