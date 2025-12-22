# backtick_javascript: true
require 'native'
require 'opal_vite/concerns/v1/vue_helpers'
require_relative '../services/counter_service'

# Counter App - Vue.js component defined in Ruby
#
# This component demonstrates two solutions for reducing backtick JavaScript:
#
# 【解決策①】Service Pattern (ロジック分離)
#   - Business logic is in CounterService (pure Ruby)
#   - Vue component only syncs state
#   - Service can be tested and reused independently
#
# 【解決策②】vue_method/vue_computed_fn helpers
#   - Helpers wrap Vue's `this` in Native for Ruby-style access
#   - Usage: vue_method { |vm| vm[:count] += 1 }
#
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
    # 解決策① - Service instance holds business logic
    service = CounterService.new

    options = {
      data: vue_fn { { count: service.count }.to_n },

      computed: {
        # 解決策② - vue_computed_fn for Ruby-style computed properties
        doubled: vue_computed_fn { |vm| vm[:count] * 2 },
        absolute: vue_computed_fn { |vm|
          count = vm[:count]
          count < 0 ? -count : count
        }
      },

      methods: {
        # 解決策①+② combined:
        # - Business logic in service (pure Ruby)
        # - vue_method to sync state to Vue
        increment: vue_method { |vm|
          service.increment                    # ① Service handles logic
          vm[:count] = service.count           # ① Sync to Vue
          console_log("Incremented to: #{service.count}")
        },

        decrement: vue_method { |vm|
          service.decrement
          vm[:count] = service.count
          console_log("Decremented to: #{service.count}")
        },

        reset: vue_method { |vm|
          service.reset
          vm[:count] = service.count
          console_log("Reset to zero")
        }
      },

      template: TEMPLATE,

      mounted: vue_hook { |vm|
        console_log("Counter component mounted (from Ruby with Service pattern!)")
      }
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
