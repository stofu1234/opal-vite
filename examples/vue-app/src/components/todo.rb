# backtick_javascript: true
require 'native'
require 'opal_vite/concerns/vue_helpers'

# Todo App - Vue.js component defined in Ruby
class TodoApp
  extend VueHelpers

  def self.get_template
    # Get template from a hidden element in the DOM
    `document.getElementById('todo-template').innerHTML`
  end

  def self.create_app
    template = get_template
    options = {
      data: `function() {
        var STORAGE_KEY = 'opal-vue-todos';
        var saved = localStorage.getItem(STORAGE_KEY);
        var todos = saved ? JSON.parse(saved) : [];
        return {
          newTodo: '',
          todos: todos,
          nextId: todos.length > 0 ? Math.max.apply(null, todos.map(function(t) { return t.id; })) + 1 : 1,
          storageKey: STORAGE_KEY
        };
      }`,
      computed: `{
        remaining: function() {
          return this.todos.filter(function(t) { return !t.completed; }).length;
        },
        completed: function() {
          return this.todos.filter(function(t) { return t.completed; }).length;
        }
      }`,
      methods: `{
        addTodo: function() {
          var text = this.newTodo.trim();
          if (!text) return;

          this.todos.push({
            id: this.nextId++,
            text: text,
            completed: false
          });
          this.newTodo = '';
          this.saveTodos();
          console.log('Todo added:', text);
        },
        removeTodo: function(id) {
          var index = this.todos.findIndex(function(t) { return t.id === id; });
          if (index > -1) {
            var removed = this.todos.splice(index, 1);
            this.saveTodos();
            console.log('Todo removed:', removed[0].text);
          }
        },
        clearCompleted: function() {
          this.todos = this.todos.filter(function(t) { return !t.completed; });
          this.saveTodos();
          console.log('Cleared completed todos');
        },
        saveTodos: function() {
          localStorage.setItem(this.storageKey, JSON.stringify(this.todos));
          console.log('Todos saved to localStorage');
        }
      }`,
      template: template,
      mounted: `function() {
        console.log('Todo component mounted (from Ruby!)');
        console.log('Loaded', this.todos.length, 'todos from localStorage');
      }`
    }

    VueHelpers.create_app(options)
  end

  def self.mount(selector)
    app = self.create_app
    app.mount(selector)
    console_log("TodoApp mounted to #{selector}")
    app
  end
end
