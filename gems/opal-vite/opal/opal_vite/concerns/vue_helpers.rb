# backtick_javascript: true

# VueHelpers - DSL helpers for Vue.js 3 applications with Opal
# Reduces backtick JavaScript usage in Vue components
module VueHelpers
  extend self  # Makes all methods available as module methods
  # ===================
  # Vue Access
  # ===================

  # Get Vue from window
  def vue
    `window.Vue`
  end

  # Create a Vue application
  # @param options [Hash] Vue component options (data, methods, computed, template, etc.)
  # @return [Native] Vue app instance
  def create_app(options = {})
    Native(`window.Vue.createApp(#{options.to_n})`)
  end

  # Create a reactive ref
  # @param initial_value [Object] Initial value
  # @return [Native] Vue ref
  def vue_ref(initial_value)
    Native(`window.Vue.ref(#{initial_value})`)
  end

  # Create a reactive object
  # @param object [Hash] Object to make reactive
  # @return [Native] Vue reactive object
  def vue_reactive(object)
    Native(`window.Vue.reactive(#{object.to_n})`)
  end

  # Create a computed property
  # @param getter [Proc] Getter function
  # @return [Native] Vue computed ref
  def vue_computed(&getter)
    Native(`window.Vue.computed(#{getter})`)
  end

  # Watch a reactive source
  # @param source [Native] Reactive source to watch
  # @param callback [Proc] Callback function
  def vue_watch(source, &callback)
    `window.Vue.watch(#{source}, #{callback})`
  end

  # ===================
  # Component Definition Helpers
  # ===================

  # Define component data as a function
  # @param data_hash [Hash] Initial data
  # @return [Proc] Data function for Vue component
  def data_fn(data_hash)
    -> { data_hash.to_n }
  end

  # Define methods hash for Vue component
  # @param methods_hash [Hash] Methods with name => proc
  # @return [Hash] Methods object for Vue component
  def methods_obj(methods_hash)
    result = {}
    methods_hash.each do |name, proc|
      result[name] = proc
    end
    result.to_n
  end

  # Define computed properties hash
  # @param computed_hash [Hash] Computed properties with name => proc
  # @return [Hash] Computed object for Vue component
  def computed_obj(computed_hash)
    result = {}
    computed_hash.each do |name, proc|
      result[name] = proc
    end
    result.to_n
  end

  # ===================
  # Lifecycle Hooks
  # ===================

  # onMounted hook
  def on_mounted(&block)
    `window.Vue.onMounted(#{block})`
  end

  # onUnmounted hook
  def on_unmounted(&block)
    `window.Vue.onUnmounted(#{block})`
  end

  # onUpdated hook
  def on_updated(&block)
    `window.Vue.onUpdated(#{block})`
  end

  # onBeforeMount hook
  def on_before_mount(&block)
    `window.Vue.onBeforeMount(#{block})`
  end

  # onBeforeUnmount hook
  def on_before_unmount(&block)
    `window.Vue.onBeforeUnmount(#{block})`
  end

  # ===================
  # Window/Global Access
  # ===================

  # Get a property from window
  def window_get(key)
    `window[#{key}]`
  end

  # Set a property on window
  def window_set(key, value)
    `window[#{key}] = #{value}`
  end

  # ===================
  # Console
  # ===================

  # Console log
  def console_log(*args)
    `console.log(...#{args})`
  end

  # Console warn
  def console_warn(*args)
    `console.warn(...#{args})`
  end

  # Console error
  def console_error(*args)
    `console.error(...#{args})`
  end

  # ===================
  # DOM Events
  # ===================

  # Execute block when DOM is ready
  def on_dom_ready(&block)
    `document.addEventListener('DOMContentLoaded', #{block})`
  end

  # ===================
  # DOM Query
  # ===================

  # Query single element
  def query(selector)
    `document.querySelector(#{selector})`
  end

  # Query all elements
  def query_all(selector)
    `Array.from(document.querySelectorAll(#{selector}))`
  end

  # Get element by ID
  def get_element_by_id(id)
    `document.getElementById(#{id})`
  end

  # ===================
  # Timing
  # ===================

  # Set timeout
  def set_timeout(delay_ms, &block)
    `setTimeout(#{block}, #{delay_ms})`
  end

  # Set interval
  def set_interval(interval_ms, &block)
    `setInterval(#{block}, #{interval_ms})`
  end

  # Clear timeout
  def clear_timeout(timeout_id)
    `clearTimeout(#{timeout_id})`
  end

  # Clear interval
  def clear_interval(interval_id)
    `clearInterval(#{interval_id})`
  end

  # ===================
  # LocalStorage
  # ===================

  # Get from localStorage
  def storage_get(key)
    `localStorage.getItem(#{key})`
  end

  # Set to localStorage
  def storage_set(key, value)
    `localStorage.setItem(#{key}, #{value})`
  end

  # Remove from localStorage
  def storage_remove(key)
    `localStorage.removeItem(#{key})`
  end

  # ===================
  # JSON
  # ===================

  # Parse JSON string
  def parse_json(json_string)
    `JSON.parse(#{json_string})`
  end

  # Stringify to JSON
  def to_json_string(object)
    `JSON.stringify(#{object})`
  end

  # ===================
  # Type Conversion
  # ===================

  # Parse string to integer
  def parse_int(value, radix = 10)
    `parseInt(#{value}, #{radix})`
  end

  # Parse string to float
  def parse_float(value)
    `parseFloat(#{value})`
  end

  # Check if value is NaN
  def is_nan?(value)
    `Number.isNaN(#{value})`
  end
end
