# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'React + Opal App', type: :feature do
  describe 'app initialization' do
    it 'mounts the React app' do
      expect(page).to have_css('#root .app')
    end

    it 'displays the header badges' do
      expect(page).to have_css('.badge-ruby', text: 'Ruby')
      expect(page).to have_css('.badge-react', text: 'React')
      expect(page).to have_css('.badge-vite', text: 'Vite')
    end

    it 'displays the footer' do
      expect(page).to have_css('.app-footer')
    end
  end

  describe 'Counter component' do
    let(:counter_container) { '.counter-container' }
    let(:count_value) { '.count-value' }
    let(:increment_btn) { '.btn-increment' }
    let(:decrement_btn) { '.btn-decrement' }
    let(:reset_btn) { '.btn-reset' }

    it 'displays initial count of 0' do
      expect(page).to have_css(count_value, text: '0')
    end

    it 'displays zero status initially' do
      expect(page).to have_css('.zero', text: 'Zero')
    end

    it 'increments the counter' do
      find(increment_btn).click
      expect(page).to have_css(count_value, text: '1')

      find(increment_btn).click
      expect(page).to have_css(count_value, text: '2')
    end

    it 'shows positive status when count is positive' do
      find(increment_btn).click
      expect(page).to have_css('.positive', text: 'Positive')
    end

    it 'decrements the counter' do
      find(decrement_btn).click
      expect(page).to have_css(count_value, text: '-1')
    end

    it 'shows negative status when count is negative' do
      find(decrement_btn).click
      expect(page).to have_css('.negative', text: 'Negative')
    end

    it 'resets the counter to zero' do
      # Increment a few times
      3.times { find(increment_btn).click }
      expect(page).to have_css(count_value, text: '3')

      # Reset
      find(reset_btn).click
      expect(page).to have_css(count_value, text: '0')
      expect(page).to have_css('.zero', text: 'Zero')
    end
  end

  describe 'TodoList component' do
    let(:todo_container) { '.todo-container' }
    let(:todo_input) { '.todo-input' }
    let(:add_btn) { '.btn-add' }
    let(:todo_list) { '.todo-list' }
    let(:todo_item) { '.todo-item' }

    it 'displays empty state initially' do
      expect(page).to have_css('.empty-state', text: 'No todos yet')
    end

    it 'has an input field with placeholder' do
      input = find(todo_input)
      expect(input[:placeholder]).to include('Add a new todo')
    end

    it 'adds a new todo' do
      find(todo_input).set('Test todo item')
      find(add_btn).click

      expect(page).to have_css(todo_item, count: 1)
      expect(page).to have_css('.todo-text', text: 'Test todo item')
    end

    it 'clears input after adding todo' do
      find(todo_input).set('Another todo')
      find(add_btn).click

      input = find(todo_input)
      expect(input.value).to eq('')
    end

    it 'adds todo by pressing Enter' do
      input = find(todo_input)
      input.set('Enter key todo')
      input.native.send_keys(:enter)

      expect(page).to have_css('.todo-text', text: 'Enter key todo')
    end

    it 'toggles todo completion' do
      # Add a todo
      find(todo_input).set('Toggleable todo')
      find(add_btn).click

      # Click checkbox to complete
      find('.todo-checkbox').click
      expect(page).to have_css('.todo-item.completed')

      # Click again to uncomplete
      find('.todo-checkbox').click
      expect(page).to have_no_css('.todo-item.completed')
    end

    it 'removes a todo' do
      # Add a todo
      find(todo_input).set('Todo to remove')
      find(add_btn).click
      expect(page).to have_css(todo_item, count: 1)

      # Remove it
      find('.btn-remove').click
      expect(page).to have_no_css(todo_item)
      expect(page).to have_css('.empty-state')
    end

    it 'displays todo stats' do
      # Add multiple todos
      find(todo_input).set('Todo 1')
      find(add_btn).click
      find(todo_input).set('Todo 2')
      find(add_btn).click
      find(todo_input).set('Todo 3')
      find(add_btn).click

      expect(page).to have_css('.todo-stats', text: 'Total: 3')
      expect(page).to have_css('.todo-stats', text: 'Completed: 0')
      expect(page).to have_css('.todo-stats', text: 'Active: 3')

      # Complete one todo
      all('.todo-checkbox').first.click

      expect(page).to have_css('.todo-stats', text: 'Completed: 1')
      expect(page).to have_css('.todo-stats', text: 'Active: 2')
    end

    it 'does not add empty todos' do
      # Try to add empty todo
      find(add_btn).click

      # Should still show empty state
      expect(page).to have_css('.empty-state')
    end
  end

  describe 'Greeting component' do
    it 'displays greeting container' do
      # The Greeting component should exist
      # We'll check for the component structure
      expect(page).to have_css('.components-grid')
    end
  end

  describe 'Ruby integration' do
    it 'exposes rubyCommands to window' do
      result = page.evaluate_script('typeof window.rubyCommands')
      expect(result).to eq('object')
    end

    it 'rubyCommands object is not null' do
      result = page.evaluate_script('window.rubyCommands !== null')
      expect(result).to be true
    end
  end
end
