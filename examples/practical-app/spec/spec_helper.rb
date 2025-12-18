# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'
require 'opal/vite/testing/stable_helpers'

# Load support files (if any additional helpers exist)
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

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
Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3001')
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
    wait_for_stimulus_ready
    page.execute_script('localStorage.clear()')
    visit '/'
    # Wait for Opal/Stimulus to load again
    wait_for_stimulus_ready
    # Wait for DOM to stabilize after Opal initialization
    wait_for_dom_stable
  end

  # Wait for Stimulus controllers to be fully connected
  def wait_for_stimulus_ready(timeout: 15)
    start_time = Time.now
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          // Check if Stimulus application exists
          if (typeof Stimulus === 'undefined') return false;

          // Check if controllers are connected by verifying their targets
          var todoEl = document.querySelector('[data-controller~="todo"]');
          var themeEl = document.querySelector('[data-controller~="theme"]');
          var inputEl = document.querySelector('[data-todo-target="input"]');

          if (!todoEl || !themeEl || !inputEl) return false;

          // Check if theme button has been initialized (has Dark Mode text)
          var themeBtn = document.querySelector('[data-action*="theme#toggle"]');
          if (!themeBtn || !themeBtn.textContent.includes('Mode')) return false;

          return true;
        })()
      JS
      return if result

      elapsed = Time.now - start_time
      raise Capybara::ElementNotFound, "Stimulus controllers not ready within #{timeout}s" if elapsed > timeout

      sleep 0.1
    end
  end

  # Helper to wait for element with JS polling
  def wait_for_element_ready(selector, timeout: 10)
    start_time = Time.now
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          var el = document.querySelector('#{selector}');
          return el !== null && el.offsetParent !== null;
        })()
      JS
      return if result

      elapsed = Time.now - start_time
      raise Capybara::ElementNotFound, "Timeout waiting for: #{selector}" if elapsed > timeout

      sleep 0.1
    end
  end

  # Retry helper for flaky operations with browser reload
  # Usage: with_browser_retry(max_attempts: 5) { your_code_here }
  def with_browser_retry(max_attempts: 5, &block)
    attempts = 0
    begin
      attempts += 1
      block.call
    rescue Capybara::ElementNotFound, Ferrum::TimeoutError, Timeout::Error => e
      if attempts < max_attempts
        warn "[Retry #{attempts}/#{max_attempts}] #{e.class}: #{e.message.lines.first.chomp}"
        # Reload browser and wait for Stimulus ready
        visit '/'
        wait_for_stimulus_ready
        page.execute_script('localStorage.clear()')
        visit '/'
        wait_for_stimulus_ready
        wait_for_dom_stable
        retry
      else
        raise
      end
    end
  end
end
