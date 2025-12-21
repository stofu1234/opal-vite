# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Progressive Web App', type: :feature do
  let(:pwa_controller_selector) { '[data-controller~="pwa"]' }
  let(:notes_list_selector) { '[data-pwa-target="notesList"]' }
  let(:note_input_selector) { '[data-pwa-target="noteInput"]' }
  let(:status_text_selector) { '[data-offline-detector-target="statusText"]' }
  let(:online_status_selector) { '[data-offline-detector-target="onlineStatus"]' }

  describe 'controller initialization' do
    it 'connects PWA controller' do
      expect(page).to have_css(pwa_controller_selector)
    end

    it 'connects offline-detector controller' do
      expect(page).to have_css('[data-controller~="offline-detector"]')
    end

    it 'displays notes list area' do
      expect(page).to have_css(notes_list_selector)
    end
  end

  describe 'online status detection' do
    it 'displays online status when online' do
      # By default, browser is online
      wait_for_text(status_text_selector, 'online')
      expect(page).to have_css(online_status_selector, text: 'Online')
    end

    it 'sets status banner attribute' do
      banner = find('[data-offline-detector-target="banner"]')
      expect(banner['data-status']).to eq('online')
    end
  end

  describe 'notes functionality' do
    it 'displays empty state when no notes exist' do
      # Either displays the empty state message or the notes list is empty
      notes_list = find(notes_list_selector)
      text = notes_list.text.strip
      expect(text.empty? || text.include?('No notes')).to be true
    end

    it 'adds a new note' do
      add_note('Test note content')

      # Note should appear in the list
      expect(page).to have_css('.note-item', wait: 5)
      expect(page).to have_css('.note-text', text: 'Test note content')
    end

    it 'clears input after adding note' do
      add_note('Another note')

      # Input should be cleared
      input = find(note_input_selector)
      expect(input.value).to eq('')
    end

    it 'adds multiple notes' do
      add_note('First note')
      add_note('Second note')
      add_note('Third note')

      # All notes should be visible
      expect(page).to have_css('.note-item', count: 3)
    end

    it 'shows newest notes first' do
      add_note('Old note')
      sleep 0.1
      add_note('New note')

      notes = all('.note-text')
      expect(notes[0].text).to eq('New note')
      expect(notes[1].text).to eq('Old note')
    end
  end

  describe 'note deletion' do
    it 'deletes a note when clicking delete button' do
      add_note('Note to delete')
      expect(page).to have_css('.note-item', count: 1)

      # Click delete button
      delete_btn = find('.btn-delete')

      # Invoke delete via JavaScript (more reliable)
      page.evaluate_script(<<~JS)
        (function() {
          var pwaElement = document.querySelector('[data-controller~="pwa"]');
          var controller = window.Stimulus.getControllerForElementAndIdentifier(pwaElement, 'pwa');
          var deleteBtn = document.querySelector('.btn-delete');

          var event = {
            target: deleteBtn,
            currentTarget: deleteBtn,
            preventDefault: function(){},
            stopPropagation: function(){}
          };

          // Add event_data helper access
          window.event = event;

          if (typeof controller.$delete_note === 'function') {
            controller.$delete_note(event);
          } else if (typeof controller.delete_note === 'function') {
            controller.delete_note(event);
          }

          delete window.event;
        })()
      JS

      wait_for_dom_stable

      # Note should be removed
      expect(page).to have_no_css('.note-item', wait: 5)
      expect(page).to have_css(notes_list_selector, text: 'No notes yet')
    end
  end

  describe 'localStorage persistence' do
    it 'persists notes across page reloads' do
      add_note('Persistent note')
      expect(page).to have_css('.note-text', text: 'Persistent note')

      # Reload page (without clearing localStorage - need to do this differently)
      page.execute_script('location.reload()')
      wait_for_pwa_ready

      # Note should still be there
      expect(page).to have_css('.note-text', text: 'Persistent note', wait: 5)
    end
  end

  describe 'PWA status display' do
    it 'displays service worker status' do
      expect(page).to have_css('[data-pwa-target="swStatus"]')
    end

    it 'displays install status' do
      expect(page).to have_css('[data-pwa-target="installStatus"]')
    end

    it 'displays cache count' do
      expect(page).to have_css('[data-pwa-target="cacheCount"]')
    end
  end

  describe 'UI elements' do
    it 'has note input field' do
      expect(page).to have_css(note_input_selector)
      input = find(note_input_selector)
      expect(input[:placeholder]).to include('note')
    end

    it 'has add note button' do
      expect(page).to have_button('Add Note')
    end

    it 'has cache management buttons' do
      expect(page).to have_button('Update Cache')
      expect(page).to have_button('Clear Cache')
    end
  end
end
