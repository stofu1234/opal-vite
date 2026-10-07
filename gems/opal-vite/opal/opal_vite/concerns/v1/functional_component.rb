# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # FunctionalComponent - Create React functional components with hooks in Ruby
      #
      # This module provides a DSL to create React functional components
      # while hiding backtick JavaScript internally.
      #
      # @example Basic usage with useState
      #   class CounterComponent
      #     extend FunctionalComponent
      #     extend ReactHelpers
      #
      #     def self.to_n
      #       create_component do |hooks|
      #         count, set_count = hooks.use_state(0)
      #
      #         div({ className: 'counter' },
      #           button({ onClick: set_count.with { |c| c - 1 } }, '-'),
      #           span(nil, count),
      #           button({ onClick: set_count.with { |c| c + 1 } }, '+')
      #         )
      #       end
      #     end
      #   end
      #
      module FunctionalComponent
        # Create a React functional component with hooks support
        #
        # @yield [hooks] Block that receives hooks helper and returns React element
        # @yieldparam hooks [Hooks] Hooks helper object
        # @return [Native] JavaScript function component
        def create_component(&block)
          # The hooks call React's functions directly, so pass the raw React
          # object rather than the Native wrapper ReactHelpers#react returns.
          r = react.to_n
          hooks_class = Hooks

          # Explicit return: Opal emits a multi-line x-string as a statement.
          `return (function(React, HooksClass) {
            return function(props) {
              var hooks = HooksClass.$new(React, props);
              var element = #{block.call(`hooks`)};
              if (element == null || element === #{nil}) {
                return null;
              }
              // ReactHelpers return Native-wrapped elements; React needs the
              // raw one. A raw JS element (from a backtick) is returned as is.
              if (element.$$class && element['$respond_to?']('to_n')) {
                return element.$to_n();
              }
              return element;
            };
          })(#{r}, #{hooks_class})`
        end

        # Hooks helper class - provides React hooks as Ruby methods
        class Hooks
          def initialize(react, props)
            @react = react
            @props = Native(props) if props
          end

          attr_reader :props

          # React useState hook
          #
          # @param initial_value [Object] Initial state value
          # @return [Array] [current_value, setter] pair
          #
          # @example
          #   count, set_count = hooks.use_state(0)
          #   set_count.call(5)           # Set to specific value
          #   set_count.with { |c| c + 1 } # Functional update
          def use_state(initial_value)
            react = @react
            result = `#{react}.useState(#{initial_value})`
            current = `#{result}[0]`
            setter_fn = `#{result}[1]`

            setter = StateSetter.new(setter_fn)
            [current, setter]
          end

          # React useEffect hook
          #
          # @param dependencies [Array, nil] Dependency array (nil = run every render, [] = run once)
          # @yield Effect callback
          # @yieldreturn [Proc, nil] Optional cleanup function
          #
          # @example Run on mount only
          #   hooks.use_effect([]) do
          #     console_log("Mounted!")
          #     -> { console_log("Unmounted!") }
          #   end
          #
          # @example Run when count changes
          #   hooks.use_effect([count]) do
          #     console_log("Count changed to", count)
          #   end
          def use_effect(dependencies = nil, &block)
            react = @react

            # React only accepts a cleanup function or undefined, so anything
            # else the block ends with (nil, false, a value) becomes undefined.
            # (Every Opal object has a $call method-missing stub, so check
            # respond_to? rather than the presence of $call.)
            effect_fn = `function() {
              var result = #{block.call};
              if (result == null || result === #{nil}) {
                return undefined;
              }
              if (typeof result === 'function' && !result.$$is_proc) {
                return result;
              }
              if (result['$respond_to?'] && result['$respond_to?']('call')) {
                return function() { result.$call(); };
              }
              return undefined;
            }`

            if dependencies.nil?
              `#{react}.useEffect(#{effect_fn})`
            else
              `#{react}.useEffect(#{effect_fn}, #{dependencies.to_a})`
            end
          end

          # React useMemo hook
          #
          # @param dependencies [Array] Dependency array
          # @yield Factory function
          # @return [Object] Memoized value
          #
          # @example
          #   expensive_value = hooks.use_memo([input]) do
          #     compute_expensive(input)
          #   end
          def use_memo(dependencies, &block)
            react = @react
            factory_fn = `function() { return #{block.call}; }`
            `#{react}.useMemo(#{factory_fn}, #{dependencies.to_a})`
          end

          # React useCallback hook
          #
          # @param dependencies [Array] Dependency array
          # @yield Callback function
          # @return [Native] Memoized callback
          #
          # @example
          #   handle_click = hooks.use_callback([item_id]) do
          #     on_item_click(item_id)
          #   end
          def use_callback(dependencies, &block)
            react = @react
            callback_fn = `function() { return #{block.call}; }`
            `#{react}.useCallback(#{callback_fn}, #{dependencies.to_a})`
          end

          # React useRef hook
          #
          # @param initial_value [Object] Initial ref value
          # @return [Native] Ref object with .current property
          #
          # @example
          #   input_ref = hooks.use_ref(nil)
          #   # In render: input({ ref: input_ref })
          #   # Later: input_ref.current.focus()
          def use_ref(initial_value = nil)
            react = @react
            Native(`#{react}.useRef(#{initial_value})`)
          end

          # React useReducer hook
          #
          # @param reducer [Proc] Reducer function (state, action) -> new_state
          # @param initial_state [Object] Initial state
          # @return [Array] [state, dispatch] pair
          #
          # @example
          #   reducer = ->(state, action) {
          #     case action[:type]
          #     when 'increment' then { count: state[:count] + 1 }
          #     when 'decrement' then { count: state[:count] - 1 }
          #     else state
          #     end
          #   }
          #   state, dispatch = hooks.use_reducer(reducer, { count: 0 })
          #   dispatch.call({ type: 'increment' })
          def use_reducer(reducer, initial_state)
            react = @react

            # Hand the reducer Ruby-friendly wrappers (state[:count]) and turn
            # its result back into a plain JS value for React.
            js_reducer = `function(state, action) {
              return #{reducer.call(Native(`state`), Native(`action`)).to_n};
            }`

            result = `#{react}.useReducer(#{js_reducer}, #{initial_state.to_n})`
            state = Native(`#{result}[0]`)
            dispatch_fn = `#{result}[1]`

            dispatch = ->(action) { `#{dispatch_fn}(#{action.to_n})` }
            [state, dispatch]
          end

          # React useContext hook
          #
          # @param context [Native] React context object
          # @return [Object] Current context value
          def use_context(context)
            react = @react
            `#{react}.useContext(#{context})`
          end
        end

        # State setter wrapper - provides functional update support
        class StateSetter
          def initialize(setter_fn)
            @setter_fn = setter_fn
          end

          # Set state to a specific value
          #
          # @param value [Object] New state value
          def call(value)
            `#{@setter_fn}(#{value})`
          end

          # Functional state update
          # Returns a callback function for use in onClick etc.
          #
          # @yield [current] Block receives current value and returns new value
          # @return [Native] JavaScript callback function
          #
          # @example
          #   button({ onClick: set_count.with { |c| c + 1 } }, '+')
          def with(&block)
            setter_fn = @setter_fn
            # Opal emits a multi-line x-string as a statement (no implicit
            # return), and a bare anonymous function statement is a
            # JavaScript syntax error, so return explicitly.
            `return function() {
              #{setter_fn}(function(current) {
                return #{block.call(`current`)};
              });
            }`
          end

          # Create a callback that sets to a specific value
          #
          # @param value [Object] Value to set
          # @return [Native] JavaScript callback function
          #
          # @example
          #   button({ onClick: set_count.to(0) }, 'Reset')
          def to(value)
            setter_fn = @setter_fn
            `function() { #{setter_fn}(#{value}); }`
          end
        end
      end
    end
  end
end

# Alias for easy access
FunctionalComponent = OpalVite::Concerns::V1::FunctionalComponent
