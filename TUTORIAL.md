# Opal + Vite Tutorial

A comprehensive guide to building web applications with Ruby using Opal and Vite.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Part 1: Hello World](#part-1-hello-world)
4. [Part 2: Understanding the Compilation](#part-2-understanding-the-compilation)
5. [Part 3: Working with DOM](#part-3-working-with-dom)
6. [Part 4: Using Stimulus Controllers](#part-4-using-stimulus-controllers)
7. [Part 5: Building a Counter App](#part-5-building-a-counter-app)
8. [Part 6: Building a Todo App](#part-6-building-a-todo-app)
9. [Next Steps](#next-steps)

## Introduction

This tutorial will teach you how to:
- Write Ruby code that runs in the browser
- Use Vite for fast development
- Build interactive applications with Stimulus
- Work with browser APIs from Ruby

By the end, you'll have built a fully functional Todo application entirely in Ruby!

## Prerequisites

- **Node.js** 18+ and **pnpm** installed
- **Ruby** 3.0+ and **Bundler** installed
- Basic knowledge of Ruby
- Basic understanding of HTML/CSS
- Familiarity with web development concepts

## Part 1: Hello World

Let's create your first Opal + Vite project.

### Step 1: Create Project Structure

```bash
mkdir my-opal-app
cd my-opal-app

# Create directories
mkdir -p app/opal
mkdir -p app/javascript
```

### Step 2: Initialize Package Files

**package.json:**
```json
{
  "name": "my-opal-app",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "vite": "^5.0.0"
  },
  "devDependencies": {
    "vite-plugin-opal": "workspace:*"
  }
}
```

**Gemfile:**
```ruby
source 'https://rubygems.org'

gem 'opal', '~> 1.8'
gem 'opal-vite', path: '../../gems/opal-vite'
```

### Step 3: Configure Vite

**vite.config.ts:**
```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal'],
      sourceMap: true
    })
  ],
  server: {
    port: 3000
  }
})
```

### Step 4: Create Your First Ruby File

**app/opal/application.rb:**
```ruby
puts "Hello from Ruby!"
puts "This code is running in the browser!"

# Try some Ruby features
numbers = [1, 2, 3, 4, 5]
squared = numbers.map { |n| n ** 2 }
puts "Squared numbers: #{squared.inspect}"
```

### Step 5: Create JavaScript Loader

**app/javascript/application.js:**
```javascript
// Import the Ruby file
import '../opal/application.rb'

console.log('JavaScript loaded!')
```

### Step 6: Create HTML Page

**index.html:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Opal App</title>
  </head>
  <body>
    <h1>My First Opal + Vite App</h1>
    <p>Open the browser console to see Ruby output!</p>

    <script type="module" src="/app/javascript/application.js"></script>
  </body>
</html>
```

### Step 7: Install and Run

```bash
# Install dependencies
bundle install
pnpm install

# Start development server
pnpm dev
```

Open `http://localhost:3000` and check the browser console. You should see:
```
Hello from Ruby!
This code is running in the browser!
Squared numbers: [1, 4, 9, 16, 25]
JavaScript loaded!
```

🎉 **Congratulations!** You've just run Ruby code in the browser!

## Part 2: Understanding the Compilation

### How It Works

1. **You write Ruby:** `app/opal/application.rb`
2. **Vite imports it:** `import '../opal/application.rb'`
3. **Plugin compiles it:** Ruby → JavaScript via Opal compiler
4. **Browser runs it:** JavaScript executes in browser

### Viewing Compiled Output

The compiled JavaScript is available in your browser's DevTools:

1. Open DevTools (F12)
2. Go to Sources tab
3. Find `application.rb` in the file tree
4. You'll see the compiled JavaScript

### Source Maps

Source maps let you debug Ruby code directly in the browser:

1. Set a `debugger` statement in your Ruby code:
   ```ruby
   puts "Before debugger"
   `debugger`
   puts "After debugger"
   ```

2. Open DevTools and the debugger will pause
3. You can inspect variables and step through Ruby code!

### Ruby to JavaScript Examples

**Ruby:**
```ruby
class Person
  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet
    "Hello, I'm #{@name} and I'm #{@age} years old"
  end
end

person = Person.new("Alice", 30)
puts person.greet
```

This compiles to optimized JavaScript that implements Ruby's class system.

## Part 3: Working with DOM

Ruby can interact with the DOM using JavaScript interop.

### Native Element Access

**app/opal/dom_example.rb:**
```ruby
# backtick_javascript: true

# Access DOM elements
element = `document.getElementById('myElement')`

# Modify element
`element.textContent = 'Updated from Ruby!'`

# Add event listener
`
  element.addEventListener('click', function() {
    alert('Clicked from Ruby!');
  })
`
```

### Creating Elements

```ruby
# backtick_javascript: true

# Create new element
new_div = `document.createElement('div')`
`new_div.textContent = 'Created from Ruby'`
`new_div.className = 'ruby-created'`

# Append to body
`document.body.appendChild(new_div)`
```

### The Backtick Syntax

The `` ` `` (backtick) syntax lets you write JavaScript directly in Ruby:

```ruby
# backtick_javascript: true

def update_counter(value)
  `
    const counter = document.getElementById('counter');
    counter.textContent = value;
  `
end
```

**Important:** Add `# backtick_javascript: true` at the top of files using backticks.

## Part 4: Using Stimulus Controllers

Stimulus is a JavaScript framework perfect for Opal integration. Let's build with it!

### Step 1: Add Stimulus Dependencies

**package.json:**
```json
{
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "vite": "^5.0.0"
  }
}
```

**Gemfile:**
```ruby
gem 'opal_stimulus', '~> 0.2.0'
```

Run `bundle install && pnpm install`

### Step 2: Create a Stimulus Controller in Ruby

**app/opal/controllers/hello_controller.rb:**
```ruby
# backtick_javascript: true

class HelloController < StimulusController
  self.targets = ["name", "output"]

  def connect
    puts "Hello controller connected!"
  end

  def greet
    `
      const name = this.nameTarget.value;
      this.outputTarget.textContent = 'Hello, ' + name + '!';
    `
  end
end
```

### Step 3: Register Controller

**app/opal/application.rb:**
```ruby
require 'opal_stimulus'
require 'controllers/hello_controller'

# Stimulus will auto-register controllers
puts "Application loaded!"
```

### Step 4: Use in HTML

**index.html:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Stimulus Example</title>
  </head>
  <body>
    <div data-controller="hello">
      <input
        type="text"
        data-hello-target="name"
        placeholder="Enter your name"
      />
      <button data-action="click->hello#greet">Greet</button>
      <p data-hello-target="output"></p>
    </div>

    <script type="module" src="/app/javascript/application.js"></script>
  </body>
</html>
```

**Try it:** Type a name and click "Greet" – all powered by Ruby!

## Part 5: Building a Counter App

Let's build a complete counter application with increment, decrement, and reset.

### Step 1: Create Counter Controller

**app/opal/controllers/counter_controller.rb:**
```ruby
# backtick_javascript: true

class CounterController < StimulusController
  self.targets = ["count"]
  self.values = { count: :number }

  def initialize
    super
    @count_value = 0
  end

  def connect
    puts "Counter controller connected!"
    update_display
  end

  def increment
    `this.countValue += 1`
    update_display
  end

  def decrement
    `this.countValue -= 1`
    update_display
  end

  def reset
    `this.countValue = 0`
    update_display
  end

  private

  def update_display
    `
      this.countTarget.textContent = this.countValue;
    `
  end
end
```

### Step 2: Register Controller

**app/opal/application.rb:**
```ruby
require 'opal_stimulus'
require 'controllers/counter_controller'
```

### Step 3: Create HTML

**index.html:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Counter App</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
        background: #f0f0f0;
      }
      .counter {
        background: white;
        padding: 2rem;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        text-align: center;
      }
      .count {
        font-size: 4rem;
        font-weight: bold;
        margin: 1rem 0;
        color: #333;
      }
      button {
        font-size: 1rem;
        padding: 0.5rem 1rem;
        margin: 0.25rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        background: #007bff;
        color: white;
      }
      button:hover {
        background: #0056b3;
      }
      button.reset {
        background: #dc3545;
      }
      button.reset:hover {
        background: #c82333;
      }
    </style>
  </head>
  <body>
    <div class="counter" data-controller="counter" data-counter-count-value="0">
      <h1>Counter App</h1>
      <div class="count" data-counter-target="count">0</div>
      <div>
        <button data-action="click->counter#decrement">-</button>
        <button data-action="click->counter#increment">+</button>
        <button class="reset" data-action="click->counter#reset">Reset</button>
      </div>
    </div>

    <script type="module" src="/app/javascript/application.js"></script>
  </body>
</html>
```

**Run it:** You now have a fully functional counter app written in Ruby!

## Part 6: Building a Todo App

Let's build a simple Todo app with add, delete, and toggle functionality.

### Step 1: Create Todo Controller

**app/opal/controllers/simple_todo_controller.rb:**
```ruby
# backtick_javascript: true

class SimpleTodoController < StimulusController
  self.targets = ["input", "list"]

  def connect
    puts "Todo controller connected!"
  end

  def add
    `
      const input = this.inputTarget;
      const text = input.value.trim();

      if (text === '') {
        alert('Please enter a todo!');
        return;
      }

      // Create todo item
      const li = document.createElement('li');
      li.innerHTML = \`
        <span class="todo-text">\${text}</span>
        <button class="delete-btn">Delete</button>
      \`;

      // Add delete functionality
      const deleteBtn = li.querySelector('.delete-btn');
      deleteBtn.onclick = () => li.remove();

      // Add toggle functionality
      li.onclick = (e) => {
        if (e.target !== deleteBtn) {
          li.classList.toggle('completed');
        }
      };

      // Add to list
      this.listTarget.appendChild(li);

      // Clear input
      input.value = '';
    `
  end

  def handle_enter
    `
      if (event.key === 'Enter') {
        this.add();
      }
    `
  end
end
```

### Step 2: Register Controller

**app/opal/application.rb:**
```ruby
require 'opal_stimulus'
require 'controllers/simple_todo_controller'
```

### Step 3: Create HTML with Styles

**index.html:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Simple Todo App</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      body {
        font-family: Arial, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 2rem;
      }
      .container {
        max-width: 500px;
        margin: 0 auto;
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        padding: 2rem;
      }
      h1 {
        color: #333;
        margin-bottom: 1rem;
      }
      .input-group {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1rem;
      }
      input[type="text"] {
        flex: 1;
        padding: 0.75rem;
        border: 2px solid #e0e0e0;
        border-radius: 4px;
        font-size: 1rem;
      }
      input[type="text"]:focus {
        outline: none;
        border-color: #667eea;
      }
      button {
        padding: 0.75rem 1.5rem;
        background: #667eea;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 1rem;
      }
      button:hover {
        background: #5568d3;
      }
      ul {
        list-style: none;
      }
      li {
        padding: 1rem;
        border-bottom: 1px solid #e0e0e0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
        transition: background 0.2s;
      }
      li:hover {
        background: #f5f5f5;
      }
      li.completed .todo-text {
        text-decoration: line-through;
        opacity: 0.5;
      }
      .delete-btn {
        padding: 0.25rem 0.75rem;
        background: #dc3545;
        font-size: 0.875rem;
      }
      .delete-btn:hover {
        background: #c82333;
      }
    </style>
  </head>
  <body>
    <div class="container" data-controller="simple-todo">
      <h1>📝 Simple Todo App</h1>
      <p style="color: #666; margin-bottom: 1rem;">Built with Ruby + Stimulus + Vite</p>

      <div class="input-group">
        <input
          type="text"
          data-simple-todo-target="input"
          data-action="keydown->simple-todo#handle_enter"
          placeholder="What needs to be done?"
        />
        <button data-action="click->simple-todo#add">Add</button>
      </div>

      <ul data-simple-todo-target="list"></ul>
    </div>

    <script type="module" src="/app/javascript/application.js"></script>
  </body>
</html>
```

**Try it:**
- Type a todo and click "Add" or press Enter
- Click a todo to mark it complete
- Click "Delete" to remove it

## Next Steps

Congratulations on completing the tutorial! Here's what to explore next:

### 1. Explore the Practical App Example

Check out the [practical-app example](./examples/practical-app) for advanced patterns:
- LocalStorage persistence
- Modal dialogs
- Toast notifications
- Form validation
- Complex state management

### 2. Learn Advanced Patterns

- **Cross-controller Communication:** Using CustomEvents
- **Template Cloning:** Dynamic content generation
- **Browser APIs:** Fetch, LocalStorage, WebSockets
- **Animations:** CSS transitions and animations

### 3. Build Real Applications

Try building:
- **Shopping Cart:** Product list with cart functionality
- **Weather App:** Fetch data from weather API
- **Chat Application:** Real-time messaging with WebSockets
- **Blog Platform:** CRUD operations with LocalStorage

### 4. Integrate with Rails

Explore Rails integration:
- Add Opal to existing Rails apps
- Use with Turbo and Hotwire
- Server-side rendering with Opal

### 5. Contribute

Help improve opal-vite:
- Report bugs and issues
- Submit pull requests
- Write documentation
- Share your projects

## Resources

- **Opal Documentation:** https://opalrb.com/docs/
- **Stimulus Handbook:** https://stimulus.hotwired.dev/handbook/introduction
- **Vite Guide:** https://vitejs.dev/guide/
- **opal_stimulus:** https://github.com/opal/opal_stimulus
- **Example Apps:** See `examples/` directory

## Getting Help

- **GitHub Issues:** Report bugs and request features
- **Discussions:** Ask questions and share ideas
- **Examples:** Learn from working code in `examples/`

Happy coding with Ruby in the browser! 💎✨
