# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

# Find browser path (Playwright-installed Chromium or system Chrome)
def find_browser_path
  # Check for Playwright-installed Chromium first
  playwright_browsers = Dir.glob(File.expand_path('~/.cache/ms-playwright/chromium-*/chrome-linux/chrome'))
  return playwright_browsers.last if playwright_browsers.any?

  # Check common Chrome/Chromium locations
  [
    '/usr/bin/google-chrome',
    '/usr/bin/chromium',
    '/usr/bin/chromium-browser',
    ENV['BROWSER_PATH']
  ].compact.find { |path| File.exist?(path.to_s) }
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
Capybara.default_max_wait_time = 5

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

  # Include Capybara DSL
  config.include Capybara::DSL, type: :feature

  # Reset state before each test
  config.before(:each, type: :feature) do
    # Clear localStorage
    visit '/'
    # Wait for Opal/Stimulus to load
    expect(page).to have_css('[data-controller]', wait: 10)
    page.execute_script('localStorage.clear()')
    visit '/'
    # Wait for Opal/Stimulus to load again
    expect(page).to have_css('[data-controller]', wait: 10)
  end
end
