# frozen_string_literal: true

RSpec.describe 'Modal Functionality', type: :feature do
  let(:modal_selector) { '.modal[data-controller="modal"]' }
  let(:input_selector) { '[data-todo-target="input"]' }
  let(:list_selector) { '[data-todo-target="list"]' }

  before do
    # Add a todo so we can edit it to trigger the modal
    input = find(input_selector, wait: 10)
    input.set('Test todo for modal')
    # Give browser time to process the input value
    sleep 0.3
    input.native.send_keys(:enter)
    # Wait for Opal to process the event
    sleep 1.0
    # Wait for todo to be added
    expect(page).to have_css("#{list_selector} .todo-item", wait: 10)
    expect(page).to have_content('Test todo for modal')
  end

  def open_modal
    find('[data-action*="todo#edit_todo"]', match: :first).click
    expect(page).to have_css('.modal.active', wait: 5)
  end

  def modal_element
    # Find modal even if hidden
    find(modal_selector, visible: :all)
  end

  describe 'opening modal' do
    it 'opens modal' do
      modal = modal_element
      expect(modal[:class]).not_to include('active')

      open_modal

      # Re-find the modal after it becomes active
      modal = find(modal_selector)
      expect(modal[:class]).to include('active')
    end
  end

  describe 'closing modal' do
    before { open_modal }

    it 'closes modal with close button' do
      modal = find(modal_selector)
      expect(modal[:class]).to include('active')

      find('button.modal-close').click

      expect(modal[:class]).not_to include('active')
    end

    it 'closes modal with Cancel button' do
      modal = find(modal_selector)

      within(modal_selector) do
        click_button 'Cancel'
      end

      expect(modal[:class]).not_to include('active')
    end

    it 'closes modal with Escape key' do
      modal = find(modal_selector)

      find('body').send_keys(:escape)

      expect(modal[:class]).not_to include('active')
    end
  end

  describe 'body scroll behavior' do
    it 'prevents body scroll when modal is open' do
      open_modal

      body_overflow = page.evaluate_script("window.getComputedStyle(document.body).overflow")
      expect(body_overflow).to eq('hidden')
    end

    it 'restores body scroll when modal closes' do
      open_modal

      find('button.modal-close').click

      # Wait for modal to close
      expect(page).not_to have_css('.modal.active')

      body_overflow = page.evaluate_script("window.getComputedStyle(document.body).overflow")
      expect(['visible', 'auto', '']).to include(body_overflow)
    end
  end

  describe 'focus management' do
    it 'focuses input within modal' do
      open_modal

      # Wait for focus to be set
      sleep 0.2

      focused_in_modal = page.evaluate_script(
        "document.activeElement?.closest('.modal[data-controller=\"modal\"]') !== null"
      )
      expect(focused_in_modal).to be true
    end
  end

  describe 'saving changes' do
    it 'saves changes when save button is clicked' do
      open_modal

      # Change the todo text
      modal_input = find('[data-modal-target="input"]')
      modal_input.set('Updated todo text')

      within(modal_selector) do
        click_button 'Save'
      end

      # Modal should close
      expect(page).not_to have_css('.modal.active')

      # Todo should be updated
      within(list_selector) do
        expect(page).to have_content('Updated todo text')
      end
    end
  end
end
