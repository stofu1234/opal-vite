# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'
require 'opal/vite/testing/stable_helpers'

# Find browser path (system Chrome, Playwright Chromium, or CI Chrome)
def find_browser_path
  paths = []
  paths << ENV['BROWSER_PATH'] if ENV['BROWSER_PATH']
  paths << ENV['CHROME_PATH'] if ENV['CHROME_PATH']
  paths += [
    '/usr/bin/google-chrome',
    '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium',
    '/usr/bin/chromium-browser'
  ]
  paths += Dir.glob(File.expand_path('~/.cache/ms-playwright/chromium-*/chrome-linux/chrome'))
  paths.compact.find { |path| File.exist?(path.to_s) }
end

Capybara.register_driver :cuprite do |app|
  browser_path = find_browser_path

  options = {
    window_size: [1280, 800],
    js_errors: true, # Fail tests on JS errors (catches OpalComponent runtime errors)
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

# Use the external Vite server (started via `pnpm dev` on the app's port).
Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3031')
Capybara.run_server = false
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

  config.order = :random
  Kernel.srand config.seed

  config.include Capybara::DSL, type: :feature
  config.include StableHelpers, type: :feature

  config.before(:each, type: :feature) do
    visit '/'
    wait_for_component_ready
    sleep ENV['CI'] ? 0.5 : 0.2
  end

  # Wait until the OpalComponent has rendered into #app (no Stimulus here).
  def wait_for_component_ready(timeout: 15)
    start = Time.now
    loop do
      ready = page.evaluate_script(<<~JS)
        (function() {
          var app = document.querySelector('#app');
          if (!app) return false;
          var count = app.querySelector('.count');
          return !!count && count.textContent.trim() !== '';
        })()
      JS
      return if ready

      raise Capybara::ElementNotFound, "OpalComponent not ready within #{timeout}s" if Time.now - start > timeout

      sleep 0.1
    end
  end
end
