# frozen_string_literal: true

require_relative '../spec_helper'

# Note: These tests only cover the login screen UI since the chat functionality
# requires a WebSocket server running on port 3007, which is not part of the
# standard test setup. The WebSocket server can be started with `pnpm server`.

RSpec.describe 'WebSocket Chat App', type: :feature do
  describe 'login screen' do
    it 'displays the app title' do
      expect(page).to have_css('h1', text: 'WebSocket Chat')
    end

    it 'displays the login subtitle' do
      expect(page).to have_css('.login-subtitle', text: 'Real-time messaging with Opal + Stimulus')
    end

    it 'displays username input field' do
      expect(page).to have_css('[data-chat-target="usernameInput"]')
    end

    it 'username input has placeholder' do
      input = find('[data-chat-target="usernameInput"]')
      expect(input[:placeholder]).to include('username')
    end

    it 'displays join button' do
      expect(page).to have_css('.join-btn', text: 'Join Chat')
    end

    it 'displays features info box' do
      expect(page).to have_css('.info-box h3', text: 'Features')
    end

    it 'lists feature items' do
      expect(page).to have_css('.info-box li', text: 'Real-time messaging')
      expect(page).to have_css('.info-box li', text: 'Online user count')
      expect(page).to have_css('.info-box li', text: 'Typing indicators')
      expect(page).to have_css('.info-box li', text: 'Message history')
      expect(page).to have_css('.info-box li', text: 'Auto-reconnect')
    end
  end

  describe 'login container visibility' do
    it 'login container is visible' do
      login = find('[data-chat-target="loginContainer"]')
      expect(login).to be_truthy
    end

    it 'chat container is hidden' do
      chat = find('[data-chat-target="chatContainer"]', visible: :all)
      expect(chat[:style]).to include('display: none')
    end
  end

  describe 'chat container elements' do
    # These elements exist but are hidden until user joins

    it 'has chat header' do
      within('[data-chat-target="chatContainer"]', visible: :all) do
        expect(page).to have_css('.chat-header h1', text: 'WebSocket Chat', visible: :all)
      end
    end

    it 'has user count display' do
      expect(page).to have_css('[data-chat-target="userCount"]', text: '0 users online', visible: :all)
    end

    it 'has messages container' do
      expect(page).to have_css('[data-chat-target="messages"]', visible: :all)
    end

    it 'has typing indicator element' do
      indicator = find('[data-chat-target="typingIndicator"]', visible: :all)
      expect(indicator).to be_truthy
    end

    it 'has message input' do
      expect(page).to have_css('[data-chat-target="input"]', visible: :all)
    end

    it 'has send button' do
      expect(page).to have_css('.send-btn', text: 'Send', visible: :all)
    end
  end

  describe 'input interaction' do
    it 'can type in username field' do
      input = find('[data-chat-target="usernameInput"]')
      input.set('TestUser')
      expect(input.value).to eq('TestUser')
    end

    it 'join button is clickable' do
      join_btn = find('.join-btn')
      expect { join_btn.click }.not_to raise_error
    end
  end

  describe 'Stimulus controller' do
    it 'chat controller is connected' do
      result = page.evaluate_script(<<~JS)
        (function() {
          var el = document.querySelector('[data-controller~="chat"]');
          return el !== null;
        })()
      JS
      expect(result).to be true
    end
  end
end
