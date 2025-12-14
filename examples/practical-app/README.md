# Practical App Example

A full-featured Todo application demonstrating real-world usage patterns of **Opal + Stimulus + Vite** integration.

## Features

### 📝 Todo Application (CRUD)
- ✅ Create, read, update, and delete todo items
- ✅ Toggle completion status with visual feedback
- ✅ Edit todos via modal dialog
- ✅ Clear all completed todos at once
- ✅ Real-time counter (active/completed items)
- ✅ **LocalStorage persistence** - data survives page reloads

### 📋 Form Validation
- ✅ Real-time validation feedback as you type
- ✅ Multiple validation rules:
  - Required fields
  - Minimum/maximum length
  - Pattern matching (email, etc.)
- ✅ Visual error states with descriptive messages
- ✅ Form submission with validation

### 🎭 Modal Dialogs
- ✅ Edit todo modal with smooth animations
- ✅ Close on overlay click or Escape key
- ✅ Automatic focus management
- ✅ Body scroll prevention when modal is open

### 🍞 Toast Notifications
- ✅ Success, error, info, and warning toasts
- ✅ Auto-dismiss after 3 seconds
- ✅ Smooth slide-in animations
- ✅ Event-based system for cross-controller communication

### ✨ Animations & UX
- ✅ Slide-in/slide-out animations for todo items
- ✅ Fade effects for modals and toasts
- ✅ Smooth transitions throughout
- ✅ Empty state messaging

## Getting Started

### Prerequisites

- Node.js 18+ and pnpm
- Ruby 3.0+
- Bundler

### Installation

1. **Install dependencies:**

```bash
# Install Ruby gems
bundle install

# Install npm packages
pnpm install
```

2. **Start the development server:**

```bash
pnpm dev
```

3. **Open in browser:**

Navigate to `http://localhost:3002` (or the port shown in the terminal)

## Project Structure

```
practical-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # JavaScript entry point
│   ├── opal/
│   │   ├── application.rb           # Opal entry point
│   │   └── controllers/
│   │       ├── todo_controller.rb   # Todo CRUD + LocalStorage
│   │       ├── form_controller.rb   # Form validation
│   │       ├── modal_controller.rb  # Modal dialog
│   │       └── toast_controller.rb  # Toast notifications
│   └── styles.css                   # Application styles
├── index.html                       # Main HTML page
├── vite.config.ts                   # Vite configuration
├── package.json                     # Node dependencies
└── Gemfile                          # Ruby dependencies
```

## Code Architecture

### Controllers Overview

All controllers inherit from `StimulusController` provided by the `opal_stimulus` gem, which allows you to write Stimulus controllers in Ruby.

#### 1. TodoController (`todo_controller.rb`)

**Purpose:** Manages the complete todo lifecycle with LocalStorage persistence.

**Key Patterns:**

- **Inline JavaScript with backticks:** Uses Opal's `` ` `` syntax to write JavaScript directly in Ruby methods
- **Helper methods in connect:** Defines JavaScript functions (`getTodos`, `saveTodos`, `addTodoToDOM`) in the `connect` lifecycle hook
- **Template cloning:** Uses HTML `<template>` element for dynamic content generation
- **CustomEvent communication:** Listens for `update-todo` events from the modal

**Methods:**
- `connect` - Initialize helper methods and load todos from LocalStorage
- `add_todo` - Create new todo item
- `toggle_todo` - Toggle completion status
- `delete_todo` - Remove todo item
- `edit_todo` - Open modal for editing
- `clear_completed` - Remove all completed todos

**Code Example:**
```ruby
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

    // Add to LocalStorage
    const todos = this.getTodos();
    todos.push(todo);
    this.saveTodos(todos);

    // Add to DOM
    this.addTodoToDOM(todo);

    // Clear input and show success
    input.value = '';
    const successEvent = new CustomEvent('show-toast', {
      detail: { message: 'Todo added!', type: 'success' }
    });
    window.dispatchEvent(successEvent);

    this.updateCount();
  `
end
```

#### 2. FormController (`form_controller.rb`)

**Purpose:** Provides real-time form validation with visual feedback.

**Key Patterns:**
- **Data attribute configuration:** Validation rules defined via HTML data attributes
- **Inline validation logic:** All validation happens in JavaScript for immediate feedback
- **Progressive enhancement:** Works with standard HTML forms

**Validation Rules:**
- `data-required` - Field must not be empty
- `data-min-length` - Minimum character length
- `data-max-length` - Maximum character length
- `data-pattern` - Regex pattern matching

**Methods:**
- `validate` - Validate input on change
- `submit` - Validate entire form on submission

#### 3. ModalController (`modal_controller.rb`)

**Purpose:** Manages modal dialog state and animations.

**Key Patterns:**
- **Event-driven opening:** Listens for global `open-modal` events
- **Focus management:** Automatically focuses input when opened
- **Keyboard shortcuts:** Close on Escape key
- **Body scroll lock:** Prevents background scrolling

**Methods:**
- `connect` - Set up event listeners
- `open` - Show modal with animation
- `close` - Hide modal and reset state
- `close_on_overlay` - Close when clicking outside
- `close_on_escape` - Close on Escape key
- `save` - Dispatch save event with form data

#### 4. ToastController (`toast_controller.rb`)

**Purpose:** Display temporary notification messages.

**Key Patterns:**
- **Global event listener:** Listens for `show-toast` events from any controller
- **Auto-dismiss:** Toasts automatically disappear after 3 seconds
- **Type-based styling:** Different icons and colors for success/error/warning/info
- **Flexible container:** Can use local or global toast container

**Methods:**
- `connect` - Set up global event listener
- `show` - Display toast notification
- `show_test` - Show random toast for testing

## Key Technical Concepts

### 1. Backtick JavaScript

Opal allows you to write inline JavaScript using backticks:

```ruby
def my_method
  `
    // This is JavaScript code
    console.log('Hello from JavaScript!');
    const value = this.inputTarget.value;
    return value;
  `
end
```

**Important:** Inside backticks, `this` refers to the controller instance, and `event` is available as a global variable in action handlers.

### 2. Stimulus Targets

Define targets in your controller:

```ruby
class MyController < StimulusController
  self.targets = ["input", "output"]
end
```

Access them in HTML:

```html
<div data-controller="my">
  <input data-my-target="input">
  <div data-my-target="output"></div>
</div>
```

And in your code:

```ruby
def my_action
  `
    const value = this.inputTarget.value;
    this.outputTarget.textContent = value;
  `
end
```

### 3. Stimulus Values

Define typed values that sync with data attributes:

```ruby
class MyController < StimulusController
  self.values = { count: :number, name: :string }
end
```

```html
<div data-controller="my" data-my-count-value="0" data-my-name-value="John">
```

Access in code:

```ruby
def increment
  `
    this.countValue += 1;
    console.log(this.nameValue); // "John"
  `
end
```

### 4. CustomEvent Communication

Controllers communicate via CustomEvents:

**Dispatching:**
```ruby
def notify
  `
    const event = new CustomEvent('show-toast', {
      detail: { message: 'Hello!', type: 'success' }
    });
    window.dispatchEvent(event);
  `
end
```

**Listening:**
```ruby
def connect
  `
    window.addEventListener('show-toast', (e) => {
      console.log(e.detail.message);
    });
  `
end
```

### 5. Template Cloning

Dynamic content generation using HTML templates:

```html
<template data-todo-target="template">
  <li class="todo-item">
    <span class="todo-text">Todo text</span>
  </li>
</template>
```

```ruby
def add_item
  `
    const template = this.templateTarget;
    const clone = template.content.cloneNode(true);
    const item = clone.firstElementChild;
    item.querySelector('.todo-text').textContent = 'New item';
    this.listTarget.appendChild(clone);
  `
end
```

### 6. LocalStorage Integration

Persist data in the browser:

```ruby
def save_data
  `
    const data = { name: 'John', age: 30 };
    localStorage.setItem('myData', JSON.stringify(data));
  `
end

def load_data
  `
    const stored = localStorage.getItem('myData');
    const data = stored ? JSON.parse(stored) : null;
    console.log(data);
  `
end
```

## Common Patterns

### Pattern 1: Controller Context Capture

When defining helper functions in `connect`, use `const ctrl = this` to capture the controller context:

```ruby
def connect
  `
    const ctrl = this;

    this.myHelper = function() {
      // Use 'ctrl' to access controller instance
      ctrl.listTarget.innerHTML = '';
    };
  `
end
```

**Why:** Avoids context issues when the function is called from different scopes.

### Pattern 2: Event Object Access

In Stimulus action handlers, access the event as a global variable:

```ruby
def handle_click
  `
    console.log(event.type);           // "click"
    console.log(event.currentTarget);  // The element with data-action
    console.log(event.target);         // The element that was clicked
  `
end
```

### Pattern 3: Defensive Programming

Always check for element existence before manipulation:

```ruby
def update_display
  `
    const element = this.element.querySelector('.my-element');
    if (element) {
      element.textContent = 'Updated';
    } else {
      console.warn('Element not found');
    }
  `
end
```

### Pattern 4: Variable Naming

Avoid using `self` as a variable name (conflicts with Opal internals):

```ruby
# ❌ BAD
def connect
  `const self = this;`
end

# ✅ GOOD
def connect
  `const ctrl = this;`
end
```

## Extending the App

### Adding a New Feature

Example: Add a "Mark All Complete" button

1. **Add the button to HTML:**

```html
<button data-action="click->todo#mark_all_complete">
  Mark All Complete
</button>
```

2. **Implement the method:**

```ruby
def mark_all_complete
  `
    const todos = this.getTodos();

    // Mark all as completed
    todos.forEach(todo => todo.completed = true);
    this.saveTodos(todos);

    // Update DOM
    const items = this.listTarget.querySelectorAll('.todo-item');
    items.forEach(item => item.classList.add('completed'));

    const checkboxes = this.listTarget.querySelectorAll('.todo-checkbox');
    checkboxes.forEach(cb => cb.checked = true);

    this.updateCount();

    // Show toast
    const event = new CustomEvent('show-toast', {
      detail: { message: 'All todos marked complete!', type: 'success' }
    });
    window.dispatchEvent(event);
  `
end
```

### Adding a New Controller

Example: Add a theme switcher

1. **Create the controller file:**

```ruby
# app/opal/controllers/theme_controller.rb
# backtick_javascript: true

class ThemeController < StimulusController
  def connect
    puts "Theme controller connected!"
    load_theme
  end

  def toggle
    `
      const html = document.documentElement;
      const currentTheme = html.getAttribute('data-theme') || 'light';
      const newTheme = currentTheme === 'light' ? 'dark' : 'light';

      html.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);

      const event = new CustomEvent('show-toast', {
        detail: {
          message: 'Switched to ' + newTheme + ' mode',
          type: 'info'
        }
      });
      window.dispatchEvent(event);
    `
  end

  private

  def load_theme
    `
      const theme = localStorage.getItem('theme') || 'light';
      document.documentElement.setAttribute('data-theme', theme);
    `
  end
end
```

2. **Add to HTML:**

```html
<div data-controller="theme">
  <button data-action="click->theme#toggle">
    Toggle Theme
  </button>
</div>
```

3. **Register in application.rb:**

```ruby
require 'controllers/theme_controller'
```

## Troubleshooting

### Issue: Controller not loading

**Check:**
1. Controller file is in `app/opal/controllers/`
2. Controller is required in `app/opal/application.rb`
3. Controller class name matches filename (e.g., `ThemeController` → `theme_controller.rb`)
4. The `# backtick_javascript: true` comment is at the top of the file

### Issue: Targets not found

**Check:**
1. Targets are declared: `self.targets = ["myTarget"]`
2. HTML has matching data attribute: `data-controller-name-target="myTarget"`
3. Controller is connected to the element (check browser console for "Controller connected!" message)

### Issue: LocalStorage data not persisting

**Check:**
1. Browser's LocalStorage is enabled (not in private/incognito mode)
2. Data is properly stringified: `JSON.stringify(data)`
3. Data is properly parsed: `JSON.parse(stored)`
4. Using correct storage key consistently

### Issue: Events not firing

**Check:**
1. Event name matches between dispatcher and listener
2. Listener is set up in `connect` method
3. Event is dispatched to correct target (`window`, `element`, etc.)
4. Check browser console for JavaScript errors

## Performance Tips

1. **Minimize LocalStorage operations:** Batch updates instead of saving on every change
2. **Use event delegation:** Attach listeners to parent elements instead of individual items
3. **Debounce input validation:** Wait for user to stop typing before validating
4. **Lazy load data:** Only load what's visible, paginate large lists

## Learn More

- **Opal Documentation:** https://opalrb.com/
- **Stimulus Handbook:** https://stimulus.hotwired.dev/handbook/introduction
- **Vite Documentation:** https://vitejs.dev/guide/
- **opal_stimulus Gem:** https://github.com/opal/opal_stimulus

## License

MIT
