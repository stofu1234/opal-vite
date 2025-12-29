require 'spec_helper'

RSpec.describe 'ActionCable Chat', type: :feature do
  before do
    visit '/'
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
  end
end
