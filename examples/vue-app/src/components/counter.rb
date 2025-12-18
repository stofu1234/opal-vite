# backtick_javascript: true
require 'native'
require 'opal_vite/concerns/vue_helpers'

# Counter App - Vue.js component defined in Ruby
class CounterApp
  extend VueHelpers

  TEMPLATE = <<~HTML
    <div>
      <div class="counter-display">
        <div class="count-value">{{ count }}</div>
      </div>
      <div class="counter-controls">
        <button class="btn btn-decrement" @click="decrement">−</button>
        <button class="btn btn-reset" @click="reset">Reset</button>
        <button class="btn btn-increment" @click="increment">+</button>
      </div>
      <div class="counter-info">
        <p>Current count: {{ count }}</p>
        <p class="status">
          <span v-if="count > 0" class="positive">↑ Positive</span>
          <span v-else-if="count < 0" class="negative">↓ Negative</span>
          <span v-else class="zero">● Zero</span>
        </p>
        <p style="margin-top: 0.5rem; font-size: 0.85rem; color: #999;">
          Double: {{ doubled }} | Absolute: {{ absolute }}
        </p>
      </div>
    </div>
  HTML

  def self.create_app
    # Define the Vue component options in Ruby
    options = {
      data: -> {
        `{ count: 0 }`
      },
      computed: `{
        doubled() {
          return this.count * 2;
        },
        absolute() {
          return Math.abs(this.count);
        }
      }`,
      methods: `{
        increment() {
          this.count++;
          console.log('Incremented to:', this.count);
        },
        decrement() {
          this.count--;
          console.log('Decremented to:', this.count);
        },
        reset() {
          this.count = 0;
          console.log('Reset to zero');
        }
      }`,
      template: TEMPLATE,
      mounted: `function() {
        console.log('Counter component mounted (from Ruby!)');
      }`
    }

    VueHelpers.create_app(options)
  end

  def self.mount(selector)
    app = self.create_app
    app.mount(selector)
    console_log("CounterApp mounted to #{selector}")
    app
  end
end
