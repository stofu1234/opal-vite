require 'spec_helper'

RSpec.describe 'ActionCable Chat', type: :feature do
  before do
    # Collect console errors
    @console_errors = []
    page.driver.browser.on(:console) do |msg|
      if msg.level == 'error'
        @console_errors << msg.text
      end
    end

    visit '/'
    # Wait for Opal to load
    sleep 1
  end

  after do
    # Check for console errors (excluding expected ones)
    unexpected_errors = @console_errors.reject do |error|
      # Filter out expected errors like WebSocket connection failures in test env
      error.include?('WebSocket') || error.include?('Failed to get Opal runtime')
    end

    if unexpected_errors.any?
      fail "Console errors detected: #{unexpected_errors.join(', ')}"
    end
  end

  describe 'Page structure' do
    it 'displays the page title' do
      expect(page).to have_content('ActionCable Demo')
    end

    it 'displays the description' do
      expect(page).to have_content('Real-time chat using OpalVite')
    end

    it 'has chat controller attached' do
      expect(page).to have_css('[data-controller="chat"]')
    end
  end

  describe 'Initial state' do
    it 'shows username input initially' do
      expect(page).to have_css('[data-chat-target="usernamePanel"]', visible: true)
      expect(page).to have_css('[data-chat-target="usernameInput"]')
    end

    it 'has disconnected status initially' do
      expect(page).to have_css('.connection-status.disconnected')
      expect(page).to have_content('Disconnected')
    end

    it 'chat panel is hidden initially' do
      chat_panel = find('[data-chat-target="chatPanel"]', visible: false)
      expect(chat_panel).not_to be_visible
    end

    it 'users panel is hidden initially' do
      users_panel = find('[data-chat-target="usersPanel"]', visible: false)
      expect(users_panel).not_to be_visible
    end
  end

  describe 'UI targets' do
    it 'has status target' do
      expect(page).to have_css('[data-chat-target="status"]')
    end

    it 'has statusText target' do
      expect(page).to have_css('[data-chat-target="statusText"]')
    end

    it 'has usernameInput target' do
      expect(page).to have_css('[data-chat-target="usernameInput"]')
    end

    it 'has messages target (hidden)' do
      expect(page).to have_css('[data-chat-target="messages"]', visible: false)
    end

    it 'has input target (hidden)' do
      expect(page).to have_css('[data-chat-target="input"]', visible: false)
    end

    it 'has sendButton target (hidden)' do
      expect(page).to have_css('[data-chat-target="sendButton"]', visible: false)
    end
  end

  describe 'Username input interaction' do
    it 'can type in username input' do
      input = find('[data-chat-target="usernameInput"]')
      input.fill_in with: 'TestUser'
      expect(input.value).to eq('TestUser')
    end

    it 'has Join Chat button' do
      expect(page).to have_button('Join Chat')
    end

    it 'clicking Join Chat button with username shows chat panel' do
      # Enter username
      input = find('[data-chat-target="usernameInput"]')
      input.fill_in with: 'TestUser'

      # Click Join Chat button
      click_button 'Join Chat'

      # Wait for UI update
      sleep 0.5

      # Username panel should be hidden
      username_panel = find('[data-chat-target="usernamePanel"]', visible: false)
      expect(username_panel).not_to be_visible

      # Chat panel should be visible
      expect(page).to have_css('[data-chat-target="chatPanel"]', visible: true)

      # Users panel should be visible
      expect(page).to have_css('[data-chat-target="usersPanel"]', visible: true)

      # Username should be displayed
      expect(page).to have_content('TestUser')
    end

    it 'pressing Enter in username input shows chat panel' do
      # Enter username and press Enter
      input = find('[data-chat-target="usernameInput"]')
      input.fill_in with: 'EnterUser'
      input.send_keys(:enter)

      # Wait for UI update
      sleep 0.5

      # Chat panel should be visible
      expect(page).to have_css('[data-chat-target="chatPanel"]', visible: true)
      expect(page).to have_content('EnterUser')
    end

    it 'empty username does not show chat panel' do
      # Click Join Chat without entering username
      click_button 'Join Chat'

      # Chat panel should still be hidden
      chat_panel = find('[data-chat-target="chatPanel"]', visible: false)
      expect(chat_panel).not_to be_visible

      # Username panel should still be visible
      expect(page).to have_css('[data-chat-target="usernamePanel"]', visible: true)
    end
  end

  describe 'Chat panel elements' do
    before do
      # Join chat first
      input = find('[data-chat-target="usernameInput"]')
      input.fill_in with: 'TestUser'
      click_button 'Join Chat'
      sleep 0.5
    end

    it 'shows message input field' do
      expect(page).to have_css('[data-chat-target="input"]', visible: true)
    end

    it 'shows send button' do
      expect(page).to have_button('Send')
    end

    it 'shows messages container' do
      expect(page).to have_css('[data-chat-target="messages"]', visible: true)
    end

    it 'shows typing indicator area' do
      expect(page).to have_css('[data-chat-target="typing"]', visible: true)
    end
  end
end
