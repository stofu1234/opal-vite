# backtick_javascript: true
require 'native'
require 'opal_vite/concerns/v1/vue_helpers'

# Todo App - Vue.js component defined in Ruby
#
# Demonstrates 解決策② - using vue_method helpers to reduce backtick JavaScript
# while keeping localStorage persistence working with Vue's reactivity.
#
class TodoApp
  extend VueHelpers

  STORAGE_KEY = 'opal-vue-todos'

  def self.get_template
    `document.getElementById('todo-template').innerHTML`
  end

  def self.create_app
    template = get_template

    options = {
      data: vue_fn {
        # Load from localStorage
        saved = `localStorage.getItem(#{STORAGE_KEY})`
        todos = `#{saved} ? JSON.parse(#{saved}) : []`
        next_id = 1
        `if (#{todos}.length > 0) {
          #{next_id} = Math.max.apply(null, #{todos}.map(function(t) { return t.id; })) + 1;
        }`
        {
          newTodo: '',
          todos: todos,
          nextId: next_id,
          storageKey: STORAGE_KEY
        }.to_n
      },

      # computed は Vue のリアクティビティを維持するため、直接 JS 関数を使用
      computed: `{
        remaining: function() {
          return this.todos.filter(function(t) { return !t.completed; }).length;
        },
        completed: function() {
          return this.todos.filter(function(t) { return t.completed; }).length;
        }
      }`,

      methods: {
        # 解決策② - vue_method でバッククォート削減
        # Note: vm.to_n を使って Vue の this に直接アクセスし、リアクティビティを維持
        addTodo: vue_method { |vm|
          this = vm.to_n
          text = `#{this}.newTodo.trim()`

          unless `#{text} === ''`
            next_id = `#{this}.nextId`
            todo = { id: next_id, text: text, completed: false }.to_n
            `#{this}.todos.push(#{todo})`
            `#{this}.nextId = #{next_id} + 1`
            `#{this}.newTodo = ''`

            # Save to localStorage
            storage_key = `#{this}.storageKey`
            `localStorage.setItem(#{storage_key}, JSON.stringify(#{this}.todos))`
            console_log("Todo added: #{text}")
          end
        },

        removeTodo: vue_method { |vm, id|
          this = vm.to_n
          `var index = #{this}.todos.findIndex(function(t) { return t.id === #{id}; });
           if (index > -1) {
             #{this}.todos.splice(index, 1);
           }`
          # Save to localStorage
          storage_key = `#{this}.storageKey`
          `localStorage.setItem(#{storage_key}, JSON.stringify(#{this}.todos))`
          console_log("Todo removed")
        },

        clearCompleted: vue_method { |vm|
          this = vm.to_n
          `#{this}.todos = #{this}.todos.filter(function(t) { return !t.completed; })`
          storage_key = `#{this}.storageKey`
          `localStorage.setItem(#{storage_key}, JSON.stringify(#{this}.todos))`
          console_log("Cleared completed todos")
        },

        saveTodos: vue_method { |vm|
          this = vm.to_n
          storage_key = `#{this}.storageKey`
          `localStorage.setItem(#{storage_key}, JSON.stringify(#{this}.todos))`
          console_log("Todos saved to localStorage")
        }
      },

      template: template,

      mounted: vue_hook { |vm|
        todos = vm[:todos]
        count = `#{todos}.length`
        console_log("Todo component mounted (from Ruby!)")
        console_log("Loaded #{count} todos from localStorage")
      }
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
