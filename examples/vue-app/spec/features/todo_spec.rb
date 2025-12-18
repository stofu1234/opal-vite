# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Todo App', type: :feature do
  let(:todo_selector) { '#todo-app' }
  let(:input_selector) { '#todo-app input[type="text"]' }
  let(:add_button_selector) { '#todo-app .todo-input button' }
  let(:list_selector) { '#todo-app .todo-list' }
  let(:item_selector) { '#todo-app .todo-item' }

  def add_todo(text)
    fill_in_todo(text)
    click_add_button
    expect(page).to have_css(item_selector, text: text, wait: 5)
  end

  def fill_in_todo(text)
    find(input_selector).set(text)
  end

  def click_add_button
    find(add_button_selector).click
  end

  describe 'empty state' do
    it 'shows empty state when no todos' do
      within(todo_selector) do
        expect(page).to have_css('.empty-state')
        expect(page).to have_text('No todos yet')
      end
    end
  end

  describe 'adding todos' do
    it 'adds a new todo by clicking Add button' do
      add_todo('Buy groceries')

      within(list_selector) do
        expect(page).to have_content('Buy groceries')
      end
    end

    it 'adds a new todo by pressing Enter' do
      fill_in_todo('Learn Vue.js')
      find(input_selector).native.send_keys(:enter)

      expect(page).to have_css(item_selector, text: 'Learn Vue.js', wait: 5)
    end

    it 'clears input after adding todo' do
      add_todo('Test todo')

      expect(find(input_selector).value).to eq('')
    end

    it 'does not add empty todos' do
      fill_in_todo('   ')
      click_add_button

      expect(page).to have_css('.empty-state')
    end

    it 'hides empty state after adding todo' do
      add_todo('First todo')

      within(todo_selector) do
        expect(page).not_to have_css('.empty-state')
      end
    end
  end

  describe 'toggling todos' do
    before do
      add_todo('Toggle test')
    end

    it 'marks todo as completed when checkbox is clicked' do
      checkbox = find("#{item_selector} input[type='checkbox']")
      expect(checkbox).not_to be_checked

      checkbox.click

      expect(checkbox).to be_checked
      expect(find(item_selector)[:class]).to include('completed')
    end

    it 'unmarks todo when checkbox is clicked again' do
      checkbox = find("#{item_selector} input[type='checkbox']")

      checkbox.click
      expect(checkbox).to be_checked

      checkbox.click
      expect(checkbox).not_to be_checked
    end
  end

  describe 'deleting todos' do
    before do
      add_todo('Todo to delete')
    end

    it 'deletes todo when delete button is clicked' do
      find("#{item_selector} .delete-btn").click

      expect(page).not_to have_css(item_selector)
      expect(page).to have_css('.empty-state')
    end
  end

  describe 'remaining items count' do
    it 'shows correct remaining count' do
      add_todo('Todo 1')
      add_todo('Todo 2')

      within(todo_selector) do
        expect(page).to have_css('.todo-stats', text: '2 items left')
      end
    end

    it 'updates count when todo is completed' do
      add_todo('Todo 1')
      add_todo('Todo 2')

      find("#{item_selector}:first-child input[type='checkbox']").click

      within(todo_selector) do
        expect(page).to have_css('.todo-stats', text: '1 item left')
      end
    end

    it 'uses singular form for 1 item' do
      add_todo('Single todo')

      within(todo_selector) do
        expect(page).to have_css('.todo-stats', text: '1 item left')
      end
    end
  end

  describe 'clearing completed' do
    before do
      add_todo('Keep this')
      add_todo('Complete this')
      add_todo('And this')
    end

    it 'shows clear completed button when there are completed todos' do
      expect(page).not_to have_button('Clear completed')

      find("#{item_selector}:first-child input[type='checkbox']").click

      expect(page).to have_button('Clear completed')
    end

    it 'clears all completed todos' do
      # Complete two todos
      all("#{item_selector} input[type='checkbox']")[0].click
      all("#{item_selector} input[type='checkbox']")[1].click

      click_button 'Clear completed'

      expect(page).to have_css(item_selector, count: 1)
      expect(page).to have_content('And this')
      expect(page).not_to have_content('Keep this')
      expect(page).not_to have_content('Complete this')
    end
  end

  describe 'persistence' do
    it 'persists todos in localStorage' do
      add_todo('Persistent todo')

      visit '/'
      wait_for_vue_ready

      within(list_selector) do
        expect(page).to have_content('Persistent todo')
      end
    end

    it 'persists completion state' do
      add_todo('Complete me')
      find("#{item_selector} input[type='checkbox']").click

      visit '/'
      wait_for_vue_ready

      checkbox = find("#{item_selector} input[type='checkbox']")
      expect(checkbox).to be_checked
    end
  end
end
