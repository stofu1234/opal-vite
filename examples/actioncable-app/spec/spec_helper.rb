require 'capybara/rspec'
require 'capybara/cuprite'
require 'opal/vite/testing/stable_helpers'

# Configure Capybara
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.app_host = 'http://localhost:3017'
Capybara.run_server = false

# Configure Cuprite driver
Capybara.register_driver :cuprite do |app|
  browser_path = ENV['BROWSER_PATH'] || nil

  options = {
    window_size: [1280, 800],
    js_errors: true,
    headless: ENV['HEADLESS'] != 'false',
    timeout: 15,
    process_timeout: 30,
    slowmo: ENV['SLOWMO']&.to_f
  }
  options[:browser_path] = browser_path if browser_path

  Capybara::Cuprite::Driver.new(app, **options)
end

RSpec.configure do |config|
  config.include StableHelpers, type: :feature

  config.before(:each, type: :feature) do
    Capybara.reset_sessions!
  end
end
