require 'spec_helper'

RSpec.describe 'ActionCable Chat', type: :feature do
  before do
    visit '/'
  end

  describe 'Username input' do
    it 'shows username input initially' do
      expect(page).to have_css('[data-chat-target="usernamePanel"]')
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
  end

  describe 'Page elements' do
    it 'displays the page title' do
      expect(page).to have_content('ActionCable Demo')
    end

    it 'has chat controller attached' do
      expect(page).to have_css('[data-controller="chat"]')
    end

    it 'has all required targets' do
      expect(page).to have_css('[data-chat-target="status"]')
      expect(page).to have_css('[data-chat-target="statusText"]')
      expect(page).to have_css('[data-chat-target="usernameInput"]')
      expect(page).to have_css('[data-chat-target="messages"]', visible: false)
      expect(page).to have_css('[data-chat-target="input"]', visible: false)
    end
  end

  describe 'Joining chat' do
    it 'entering username shows chat panel' do
      fill_in_username('TestUser')

      # Username panel should be hidden
      username_panel = find('[data-chat-target="usernamePanel"]', visible: false)
      expect(username_panel).not_to be_visible

      # Chat panel should be visible
      expect(page).to have_css('[data-chat-target="chatPanel"]', visible: true)
      expect(page).to have_content('TestUser')
    end

    it 'shows users panel after joining' do
      fill_in_username('TestUser')

      expect(page).to have_css('[data-chat-target="usersPanel"]', visible: true)
      expect(page).to have_content('Online Users')
    end
  end

  private

  def fill_in_username(name)
    input = find('[data-chat-target="usernameInput"]')
    input.fill_in with: name
    input.send_keys(:enter)

    # Wait for chat panel to appear
    wait_for_stable_dom do
      find('[data-chat-target="chatPanel"]', visible: true)
    end
  end
end
