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
Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3008')
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
  end

  # Wait for Stimulus controllers to be fully connected
  def wait_for_stimulus_ready(timeout: 30)
    start_time = Time.now
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          // Check if Stimulus application exists
          if (typeof Stimulus === 'undefined') return { ready: false, reason: 'Stimulus not defined' };

          // Check if all controller elements exist
          var urlDemoEl = document.querySelector('[data-controller~="url-demo"]');
          var base64DemoEl = document.querySelector('[data-controller~="base64-demo"]');
          var validationDemoEl = document.querySelector('[data-controller~="validation-demo"]');
          var clipboardDemoEl = document.querySelector('[data-controller~="clipboard-demo"]');

          if (!urlDemoEl || !base64DemoEl || !validationDemoEl || !clipboardDemoEl) {
            return { ready: false, reason: 'Elements not found' };
          }

          // Check if controllers are actually registered and connected
          var urlController = Stimulus.getControllerForElementAndIdentifier(urlDemoEl, 'url-demo');
          var base64Controller = Stimulus.getControllerForElementAndIdentifier(base64DemoEl, 'base64-demo');
          var validationController = Stimulus.getControllerForElementAndIdentifier(validationDemoEl, 'validation-demo');
          var clipboardController = Stimulus.getControllerForElementAndIdentifier(clipboardDemoEl, 'clipboard-demo');

          if (!urlController || !base64Controller || !validationController || !clipboardController) {
            return {
              ready: false,
              reason: 'Controllers not connected',
              url: !!urlController,
              base64: !!base64Controller,
              validation: !!validationController,
              clipboard: !!clipboardController
            };
          }

          return { ready: true };
        })()
      JS

      return if result && result['ready']

      elapsed = Time.now - start_time
      if elapsed > timeout
        reason = result ? result.inspect : 'unknown'
        raise Capybara::ElementNotFound, "Stimulus controllers not ready within #{timeout}s: #{reason}"
      end

      sleep 0.2
    end
  end
end
