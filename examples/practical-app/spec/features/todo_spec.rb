# frozen_string_literal: true

RSpec.describe 'Todo Functionality', type: :feature do
  let(:input_selector) { '[data-todo-target="input"]' }
  let(:list_selector) { '[data-todo-target="list"]' }

  # Add todo using stable helpers with explicit count verification
  def add_todo(text)
    # Get current count before adding
    current_count = all("#{list_selector} .todo-item", wait: 0).count

    stable_input(input_selector, text, submit_key: :enter)

    # Wait for the new todo item to appear (count should increase by 1)
    wait_for_count("#{list_selector} .todo-item", current_count + 1)
    wait_for_text(list_selector, text)
    wait_for_dom_stable
  end

  def fill_in_todo_input(text)
    stable_set(input_selector, text)
  end

  describe 'adding todos' do
    it 'adds a new todo' do
      add_todo('Buy groceries')

      # Wait for the todo to appear in the list
      expect(page).to have_css("#{list_selector} .todo-item", wait: 5)

      within(list_selector) do
        expect(page).to have_content('Buy groceries')
      end

      # Input should be cleared
      expect(find(input_selector).value).to eq('')
    end

    it 'does not add empty todos' do
      initial_count = all("#{list_selector} .todo-item").count

      fill_in_todo_input('   ')
      find(input_selector).native.send_keys(:enter)

      expect(all("#{list_selector} .todo-item").count).to eq(initial_count)
    end
  end

  describe 'toggling todos' do
    before do
      add_todo('Test todo')
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)
    end

    it 'toggles todo completion' do
      checkbox = find("#{list_selector} input[type='checkbox']", match: :first, wait: 5)
      todo_item = find("#{list_selector} .todo-item", match: :first)

      # Initially unchecked
      expect(checkbox).not_to be_checked
      expect(todo_item[:class]).not_to include('completed')

      # Toggle completion
      checkbox.click

      # Should be checked and have completed class
      expect(checkbox).to be_checked
      expect(todo_item[:class]).to include('completed')
    end
  end

  describe 'deleting todos' do
    it 'deletes a todo' do
      add_todo('Todo to delete')

      # Wait for the todo item to appear
      expect(page).to have_css("#{list_selector} .todo-item", wait: 5)
      expect(page).to have_content('Todo to delete')

      # Click delete button
      find("#{list_selector} button[data-action*='delete']", match: :first).click

      # Wait for deletion to complete
      expect(page).not_to have_css("#{list_selector} .todo-item", wait: 5)
      expect(page).not_to have_content('Todo to delete')
    end
  end

  describe 'filtering todos' do
    before do
      add_todo('Todo 1')
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)

      add_todo('Todo 2')
      expect(page).to have_css("#{list_selector} .todo-item", count: 2, wait: 5)

      # Complete first todo
      find("#{list_selector} input[type='checkbox']", match: :first).click
      expect(page).to have_css("#{list_selector} .todo-item.completed", count: 1, wait: 5)
    end

    it 'filters completed todos' do
      click_button_with_filter('completed')

      within(list_selector) do
        expect(page).to have_content('Todo 1')
        expect(page).not_to have_content('Todo 2')
      end
    end

    it 'filters active todos' do
      click_button_with_filter('active')

      within(list_selector) do
        expect(page).not_to have_content('Todo 1')
        expect(page).to have_content('Todo 2')
      end
    end

    it 'shows all todos' do
      click_button_with_filter('completed')
      click_button_with_filter('all')

      within(list_selector) do
        expect(page).to have_content('Todo 1')
        expect(page).to have_content('Todo 2')
      end
    end

    def click_button_with_filter(filter)
      find("button[data-filter='#{filter}']").click
    end
  end

  describe 'persistence' do
    it 'persists todos in localStorage' do
      add_todo('Persistent todo')
      # Wait for todo to be added to DOM and localStorage
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)

      # Reload page
      visit '/'
      expect(page).to have_css('[data-controller]', wait: 10)

      expect(page).to have_content('Persistent todo', wait: 5)
    end
  end

  describe 'todo count' do
    let(:count_selector) { '[data-todo-target="count"]' }

    it 'shows todo count' do
      add_todo('Todo 1')
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)

      add_todo('Todo 2')
      expect(page).to have_css("#{list_selector} .todo-item", count: 2, wait: 5)

      # Wait for count to update
      expect(page).to have_css(count_selector, text: /2/, wait: 5)

      # Complete one todo
      find("#{list_selector} input[type='checkbox']", match: :first).click

      # Wait for count to update after completion
      expect(page).to have_css(count_selector, text: /1/, wait: 5)
    end
  end

  describe 'clearing completed' do
    it 'clears completed todos' do
      # Add todos one by one with waits
      add_todo("Todo 1")
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)

      add_todo("Todo 2")
      expect(page).to have_css("#{list_selector} .todo-item", count: 2, wait: 5)

      add_todo("Todo 3")
      expect(page).to have_css("#{list_selector} .todo-item", count: 3, wait: 5)

      # Complete first checkbox - get fresh reference
      all("#{list_selector} input[type='checkbox']")[0].click
      # Wait for completion state to be applied
      expect(page).to have_css("#{list_selector} .todo-item.completed", count: 1, wait: 5)

      # Complete second checkbox - get fresh reference again
      all("#{list_selector} input[type='checkbox']")[1].click
      # Wait for completion state
      expect(page).to have_css("#{list_selector} .todo-item.completed", count: 2, wait: 5)

      # Click "Clear Completed" button
      click_button 'Clear Completed'

      # Wait for clearing to complete - should have 1 remaining
      expect(page).to have_css("#{list_selector} .todo-item", count: 1, wait: 5)

      within(list_selector) do
        expect(page).not_to have_content('Todo 1')
        expect(page).not_to have_content('Todo 2')
        expect(page).to have_content('Todo 3')
      end
    end
  end
end
