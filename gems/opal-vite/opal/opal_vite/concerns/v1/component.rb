# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # Component - a lightweight, framework-agnostic UI component base class.
      #
      # opal-rails users coming from hand-written opal-jquery DOM code (or
      # Hyperstack) usually just want "a base class that holds state and
      # re-renders". This provides exactly that, with no React/Vue dependency,
      # using only the native DOM. Because it is Sprockets-independent it runs
      # unchanged under Vite.
      #
      # @example
      #   class Counter < OpalComponent
      #     def initial_state
      #       { count: 0 }
      #     end
      #
      #     def render
      #       "<button>count: #{state[:count]}</button>"
      #     end
      #
      #     def after_render
      #       on('button', 'click') { set_state(count: state[:count] + 1) }
      #     end
      #   end
      #
      #   Counter.new.mount('#app')
      class Component
        attr_reader :state, :props, :el

        # @param props [Hash] immutable inputs passed from the parent/caller
        def initialize(props = {})
          @props = props
          @state = initial_state
          @el = nil
        end

        # Override to provide the initial state hash. Defaults to empty.
        def initial_state
          {}
        end

        # Override to return the component's HTML as a String.
        def render
          ''
        end

        # Optional hook run after every render. Attach event listeners here
        # (the DOM produced by #render only exists after rendering).
        def after_render; end

        # Mount the component into a DOM element.
        # @param target [String, Native] a CSS selector or a native element
        # @return [self]
        def mount(target)
          @el = resolve_el(target)
          raise "OpalComponent#mount: target not found: #{target}" if `#{@el} == null`

          do_render
          self
        end

        # Merge +partial+ into the current state and re-render (if mounted).
        # @param partial [Hash]
        # @return [Hash] the new state
        def set_state(partial)
          unless partial.is_a?(Hash)
            raise ArgumentError, "OpalComponent#set_state expects a Hash, got #{partial.class}"
          end

          @state = @state.merge(partial)
          do_render if @el
          @state
        end

        # querySelector scoped to this component's element.
        def query(selector)
          `#{@el}.querySelector(#{selector})`
        end

        # Attach an event listener to a descendant matched by +selector+.
        # The block receives the native DOM event.
        def on(selector, event, &block)
          node = query(selector)
          return if `#{node} == null`

          `#{node}.addEventListener(#{event}, #{block})`
        end

        private

        def do_render
          `#{@el}.innerHTML = #{render}`
          after_render
        end

        def resolve_el(target)
          if target.is_a?(String)
            `document.querySelector(#{target})`
          else
            target
          end
        end
      end
    end
  end
end

# Friendly top-level alias (the base class users subclass).
OpalComponent = OpalVite::Concerns::V1::Component
