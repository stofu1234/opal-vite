# backtick_javascript: true

# Main Todo controller with CRUD operations and LocalStorage persistence
class TodoController < StimulusController
  self.targets = ["list", "input", "template", "count", "emptyState"]
  self.values = { storage_key: :string }

  def initialize
    super
    @storage_key_value = "opal_todos"
  end

  def connect
    # Set up helper methods on the controller instance
    `
      const ctrl = this;

      // Listen for update-todo event from modal
      window.addEventListener('update-todo', (e) => {
        const todoId = parseInt(e.detail.todoId);
        const newText = e.detail.text;

        const todos = ctrl.getTodos();
        const todo = todos.find(t => t.id === todoId);

        if (todo) {
          todo.text = newText;
          ctrl.saveTodos(todos);

          // Update DOM
          const todoEl = document.querySelector('[data-todo-id="' + todoId + '"]');
          if (todoEl) {
            const textEl = todoEl.querySelector('.todo-text');
            if (textEl) {
              textEl.textContent = newText;
            }
          }

          // Show toast
          const toastEvent = new CustomEvent('show-toast', {
            detail: { message: 'Todo updated!', type: 'success' }
          });
          window.dispatchEvent(toastEvent);
        }
      });

      this.getTodos = function() {
        const stored = localStorage.getItem(ctrl.storageKeyValue || 'opal_todos');
        return stored ? JSON.parse(stored) : [];
      };

      this.saveTodos = function(todos) {
        localStorage.setItem(ctrl.storageKeyValue || 'opal_todos', JSON.stringify(todos));
      };

      this.addTodoToDOM = function(todo) {
        const template = ctrl.templateTarget;
        const clone = template.content.cloneNode(true);

        // Get the first element child (the <li> element)
        const todoItem = clone.firstElementChild;

        if (!todoItem) {
          console.error('Template is empty or invalid');
          return;
        }

        todoItem.setAttribute('data-todo-id', todo.id);
        if (todo.completed) {
          todoItem.classList.add('completed');
        }

        const checkbox = todoItem.querySelector('.todo-checkbox');
        if (checkbox) {
          checkbox.setAttribute('data-todo-id', todo.id);
          checkbox.checked = todo.completed;
        }

        const text = todoItem.querySelector('.todo-text');
        if (text) {
          text.textContent = todo.text;
        }

        const editBtn = todoItem.querySelector('.edit-btn');
        if (editBtn) {
          editBtn.setAttribute('data-todo-id', todo.id);
        }

        const deleteBtn = todoItem.querySelector('.delete-btn');
        if (deleteBtn) {
          deleteBtn.setAttribute('data-todo-id', todo.id);
        }

        ctrl.listTarget.appendChild(clone);
        ctrl.hideEmptyState();
      };

      this.updateCount = function() {
        const todos = ctrl.getTodos();
        const active = todos.filter(t => !t.completed).length;
        const completed = todos.filter(t => t.completed).length;

        if (ctrl.hasCountTarget) {
          ctrl.countTarget.innerHTML = active + ' active, ' + completed + ' completed';
        }

        if (todos.length === 0) {
          ctrl.showEmptyState();
        }
      };

      this.showEmptyState = function() {
        if (ctrl.hasEmptyStateTarget) {
          ctrl.emptyStateTarget.style.display = 'block';
        }
      };

      this.hideEmptyState = function() {
        if (ctrl.hasEmptyStateTarget) {
          ctrl.emptyStateTarget.style.display = 'none';
        }
      };
    `

    load_todos
    update_count
  end

  # Add new todo
  def add_todo
    `
      const input = this.inputTarget;
      const text = input.value.trim();

      if (text === '') {
        // Show validation error via toast
        const event = new CustomEvent('show-toast', {
          detail: { message: 'Please enter a todo item', type: 'error' }
        });
        window.dispatchEvent(event);
        return;
      }

      const todo = {
        id: Date.now(),
        text: text,
        completed: false,
        createdAt: new Date().toISOString()
      };

      // Add to list
      const todos = this.getTodos();
      todos.push(todo);
      this.saveTodos(todos);

      // Add to DOM with animation
      this.addTodoToDOM(todo);

      // Clear input
      input.value = '';

      // Show success toast
      const successEvent = new CustomEvent('show-toast', {
        detail: { message: 'Todo added!', type: 'success' }
      });
      window.dispatchEvent(successEvent);

      this.updateCount();
    `
  end

  # Toggle todo completion
  def toggle_todo
    `
      const checkbox = event.currentTarget;
      const todoId = parseInt(checkbox.getAttribute('data-todo-id'));

      const todos = this.getTodos();
      const todo = todos.find(t => t.id === todoId);

      if (todo) {
        todo.completed = !todo.completed;
        this.saveTodos(todos);

        // Update DOM
        const todoEl = checkbox.closest('.todo-item');
        todoEl.classList.toggle('completed');

        this.updateCount();
      }
    `
  end

  # Delete todo
  def delete_todo
    `
      const todoId = parseInt(event.currentTarget.getAttribute('data-todo-id'));
      const todos = this.getTodos();
      const filteredTodos = todos.filter(t => t.id !== todoId);

      this.saveTodos(filteredTodos);

      // Remove from DOM with animation
      const todoEl = event.currentTarget.closest('.todo-item');
      todoEl.style.animation = 'slideOut 0.3s ease-out';

      setTimeout(() => {
        todoEl.remove();
        this.updateCount();

        // Show toast
        const event = new CustomEvent('show-toast', {
          detail: { message: 'Todo deleted', type: 'info' }
        });
        window.dispatchEvent(event);
      }, 300);
    `
  end

  # Edit todo (show modal)
  def edit_todo
    `
      const todoId = parseInt(event.currentTarget.getAttribute('data-todo-id'));
      const todos = this.getTodos();
      const todo = todos.find(t => t.id === todoId);

      if (todo) {
        // Dispatch event to open modal
        const modalEvent = new CustomEvent('open-modal', {
          detail: {
            title: 'Edit Todo',
            todoId: todoId,
            todoText: todo.text
          }
        });
        window.dispatchEvent(modalEvent);
      }
    `
  end

  # Clear completed todos
  def clear_completed
    `
      const todos = this.getTodos();
      const activeTodos = todos.filter(t => !t.completed);

      this.saveTodos(activeTodos);

      // Remove completed items from DOM
      const completedItems = this.listTarget.querySelectorAll('.todo-item.completed');

      if (completedItems.length === 0) {
        const event = new CustomEvent('show-toast', {
          detail: { message: 'No completed todos to clear', type: 'info' }
        });
        window.dispatchEvent(event);
        return;
      }

      completedItems.forEach(item => {
        item.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => item.remove(), 300);
      });

      setTimeout(() => {
        this.updateCount();

        const event = new CustomEvent('show-toast', {
          detail: { message: 'Completed todos cleared', type: 'success' }
        });
        window.dispatchEvent(event);
      }, 300);
    `
  end

  # Private helper methods (JavaScript)
  def get_todos
    `this.getTodos()`
  end

  def save_todos
    # This is a placeholder - actual implementation in JS
  end

  private

  def load_todos
    `
      const todos = this.getTodos();
      todos.forEach(todo => this.addTodoToDOM(todo));

      if (todos.length === 0) {
        this.showEmptyState();
      } else {
        this.hideEmptyState();
      }
    `
  end

  def update_count
    `
      this.updateCount();
    `
  end
end
