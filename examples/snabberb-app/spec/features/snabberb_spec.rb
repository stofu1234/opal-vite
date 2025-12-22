# frozen_string_literal: true

require 'spec_helper'

# Note: Snabberb's attach() method replaces the target element entirely,
# so we cannot use within('#counter-app') or within('#todo-app').
# Instead, we target elements by their class names directly.

RSpec.describe 'Snabberb App', type: :feature do
  describe 'page load' do
    it 'displays the correct title' do
      expect(page).to have_title(/Snabberb/)
    end

    it 'displays the main heading' do
      expect(page).to have_css('h1', text: 'Snabberb + Opal + Vite')
    end
  end

  describe 'Counter component' do
    it 'renders with initial value of 0' do
      expect(page).to have_css('.count-value', text: '0')
    end

    it 'increments when clicking + button' do
      find('.btn-increment').click
      expect(page).to have_css('.count-value', text: '1')
    end

    it 'decrements when clicking - button' do
      find('.btn-decrement').click
      expect(page).to have_css('.count-value', text: '-1')
    end

    it 'resets to 0 when clicking Reset button' do
      # First increment a few times
      3.times { find('.btn-increment').click }
      expect(page).to have_css('.count-value', text: '3')

      # Then reset
      find('.btn-reset').click
      expect(page).to have_css('.count-value', text: '0')
    end

    it 'shows positive status when count > 0' do
      find('.btn-increment').click
      expect(page).to have_css('.positive', text: 'Positive')
    end

    it 'shows negative status when count < 0' do
      find('.btn-decrement').click
      expect(page).to have_css('.negative', text: 'Negative')
    end

    it 'shows zero status when count = 0' do
      expect(page).to have_css('.zero', text: 'Zero')
    end
  end

  describe 'Todo component' do
    it 'renders with empty state' do
      expect(page).to have_css('.empty-state', text: 'No todos yet')
    end

    it 'adds a todo when clicking Add button' do
      fill_in_todo('Buy groceries')
      click_button 'Add'

      expect(page).to have_css('.todo-item', count: 1)
      expect(page).to have_css('.todo-item span', text: 'Buy groceries')
      expect(page).to have_css('.todo-stats', text: '1 item left')
    end

    it 'adds a todo when pressing Enter' do
      input = find('.todo-input input[type="text"]')
      input.fill_in with: 'Walk the dog'
      input.send_keys(:enter)

      expect(page).to have_css('.todo-item', count: 1)
      expect(page).to have_css('.todo-item span', text: 'Walk the dog')
    end

    it 'clears input after adding todo' do
      fill_in_todo('Test todo')
      click_button 'Add'

      expect(find('.todo-input input[type="text"]').value).to eq('')
    end

    it 'does not add empty todos' do
      click_button 'Add'
      expect(page).to have_css('.empty-state', text: 'No todos yet')
    end

    it 'toggles todo completion' do
      fill_in_todo('Complete me')
      click_button 'Add'

      # Toggle complete
      find('.todo-item input[type="checkbox"]').click
      expect(page).to have_css('.todo-item.completed', count: 1)
      expect(page).to have_css('.todo-stats', text: '0 items left')

      # Toggle back
      find('.todo-item input[type="checkbox"]').click
      expect(page).to have_no_css('.todo-item.completed')
      expect(page).to have_css('.todo-stats', text: '1 item left')
    end

    it 'deletes a todo' do
      fill_in_todo('Delete me')
      click_button 'Add'
      expect(page).to have_css('.todo-item', count: 1)

      find('.delete-btn').click
      expect(page).to have_css('.empty-state', text: 'No todos yet')
    end

    it 'clears completed todos' do
      # Add two todos
      fill_in_todo('Todo 1')
      click_button 'Add'
      fill_in_todo('Todo 2')
      click_button 'Add'

      expect(page).to have_css('.todo-item', count: 2)

      # Complete one
      all('.todo-item input[type="checkbox"]').first.click
      expect(page).to have_css('.clear-completed', text: 'Clear completed (1)')

      # Clear completed
      click_button 'Clear completed (1)'
      expect(page).to have_css('.todo-item', count: 1)
      expect(page).to have_css('.todo-item span', text: 'Todo 2')
    end

    it 'shows correct pluralization for items left' do
      fill_in_todo('Single item')
      click_button 'Add'
      expect(page).to have_css('.todo-stats', text: '1 item left')

      fill_in_todo('Second item')
      click_button 'Add'
      expect(page).to have_css('.todo-stats', text: '2 items left')
    end
  end

  private

  def fill_in_todo(text)
    find('.todo-input input[type="text"]').fill_in with: text
  end
end
