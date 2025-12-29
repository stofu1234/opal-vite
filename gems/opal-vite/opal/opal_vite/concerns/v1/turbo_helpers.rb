# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # TurboHelpers - Ruby-friendly DSL for Hotwire Turbo integration
      #
      # This module provides methods for interacting with Turbo Drive, Frames, and Streams
      # from Opal/Stimulus controllers.
      #
      # Prerequisites:
      # - @hotwired/turbo package must be installed (npm install @hotwired/turbo)
      # - Turbo must be imported in your JavaScript entry point
      #
      # Usage:
      #   # In your main.js:
      #   import * as Turbo from "@hotwired/turbo"
      #   window.Turbo = Turbo
      #
      #   # In your Opal controller:
      #   class NavigationController < StimulusController
      #     include OpalVite::Concerns::V1::TurboHelpers
      #
      #     def navigate_to(event)
      #       turbo_visit("/dashboard")
      #     end
      #
      #     def refresh_frame
      #       reload_turbo_frame("notifications")
      #     end
      #   end
      module TurboHelpers
        # ===== Turbo Drive =====

        # Navigate to a URL using Turbo Drive
        # @param url [String] URL to navigate to
        # @param options [Hash] Visit options
        # @option options [String] :action ("advance") "advance", "replace", or "restore"
        # @option options [String] :frame Target frame ID (for frame navigation)
        # @example
        #   turbo_visit("/users/1")
        #   turbo_visit("/login", action: "replace")
        #   turbo_visit("/modal-content", frame: "modal")
        def turbo_visit(url, options = {})
          native_options = options.to_n
          if options.empty?
            `window.Turbo.visit(#{url})`
          else
            `window.Turbo.visit(#{url}, #{native_options})`
          end
        end

        # Navigate to a URL replacing the current history entry
        # @param url [String] URL to navigate to
        def turbo_replace(url)
          turbo_visit(url, action: "replace")
        end

        # Clear the Turbo Drive cache
        def turbo_clear_cache
          `window.Turbo.cache.clear()`
        end

        # Enable Turbo Drive (if previously disabled)
        def turbo_enable
          `document.documentElement.removeAttribute('data-turbo')`
        end

        # Disable Turbo Drive globally
        def turbo_disable
          `document.documentElement.setAttribute('data-turbo', 'false')`
        end

        # Check if Turbo Drive is enabled
        # @return [Boolean] true if enabled
        def turbo_enabled?
          `document.documentElement.getAttribute('data-turbo') !== 'false'`
        end

        # Set Turbo Drive progress bar delay
        # @param delay [Integer] Delay in milliseconds
        def turbo_progress_delay(delay)
          `window.Turbo.setProgressBarDelay(#{delay})`
        end

        # ===== Turbo Frames =====

        # Get a Turbo Frame element by ID
        # @param frame_id [String] Frame ID
        # @return [Native, nil] Frame element or nil
        def get_turbo_frame(frame_id)
          frame = `document.querySelector('turbo-frame#' + #{frame_id})`
          `#{frame} === null` ? nil : frame
        end

        # Reload a Turbo Frame
        # @param frame_id [String] Frame ID to reload
        # @param url [String, nil] Optional URL to load (uses src attribute if nil)
        def reload_turbo_frame(frame_id, url = nil)
          frame = get_turbo_frame(frame_id)
          return unless frame

          if url
            `#{frame}.src = #{url}`
          else
            # Trigger reload by re-setting src
            current_src = `#{frame}.src`
            `#{frame}.src = #{current_src}`
          end
        end

        # Set the src attribute of a Turbo Frame
        # @param frame_id [String] Frame ID
        # @param url [String] URL to load
        def set_frame_src(frame_id, url)
          frame = get_turbo_frame(frame_id)
          `#{frame}.src = #{url}` if frame
        end

        # Disable a Turbo Frame (prevent loading)
        # @param frame_id [String] Frame ID
        def disable_turbo_frame(frame_id)
          frame = get_turbo_frame(frame_id)
          `#{frame}.setAttribute('disabled', '')` if frame
        end

        # Enable a Turbo Frame
        # @param frame_id [String] Frame ID
        def enable_turbo_frame(frame_id)
          frame = get_turbo_frame(frame_id)
          `#{frame}.removeAttribute('disabled')` if frame
        end

        # Check if a Turbo Frame is loading
        # @param frame_id [String] Frame ID
        # @return [Boolean] true if loading
        def frame_loading?(frame_id)
          frame = get_turbo_frame(frame_id)
          return false unless frame
          `#{frame}.hasAttribute('busy')`
        end

        # Wait for a Turbo Frame to finish loading
        # @param frame_id [String] Frame ID
        # @yield Block to execute when loaded
        def on_frame_loaded(frame_id, &block)
          frame = get_turbo_frame(frame_id)
          return unless frame

          if frame_loading?(frame_id)
            `#{frame}.addEventListener('turbo:frame-load', function handler() {
              #{frame}.removeEventListener('turbo:frame-load', handler);
              #{block.call};
            })`
          else
            block.call
          end
        end

        # Get the target frame from current event
        # @return [Native, nil] Frame element from event
        def event_turbo_frame
          `event.target.closest('turbo-frame')`
        end

        # ===== Turbo Streams =====

        # Render a Turbo Stream action
        # @param action [Symbol, String] Stream action (:append, :prepend, :replace, :update, :remove, :before, :after)
        # @param target [String] Target element ID
        # @param html [String] HTML content (not needed for :remove)
        # @example
        #   turbo_stream(:append, "messages", "<div>New message</div>")
        #   turbo_stream(:remove, "message_1")
        def turbo_stream(action, target, html = nil)
          action_s = action.to_s
          template_content = html ? "<template>#{html}</template>" : ""

          stream_html = %{<turbo-stream action="#{action_s}" target="#{target}">#{template_content}</turbo-stream>}
          render_turbo_stream(stream_html)
        end

        # Render raw Turbo Stream HTML
        # @param stream_html [String] Full turbo-stream element HTML
        def render_turbo_stream(stream_html)
          `window.Turbo.renderStreamMessage(#{stream_html})`
        end

        # Append content to target element via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to append
        def turbo_append(target, html)
          turbo_stream(:append, target, html)
        end

        # Prepend content to target element via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to prepend
        def turbo_prepend(target, html)
          turbo_stream(:prepend, target, html)
        end

        # Replace target element via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to replace with
        def turbo_replace_element(target, html)
          turbo_stream(:replace, target, html)
        end

        # Update target element's content via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to update with
        def turbo_update(target, html)
          turbo_stream(:update, target, html)
        end

        # Remove target element via Turbo Stream
        # @param target [String] Target element ID
        def turbo_remove(target)
          turbo_stream(:remove, target)
        end

        # Insert content before target element via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to insert
        def turbo_before(target, html)
          turbo_stream(:before, target, html)
        end

        # Insert content after target element via Turbo Stream
        # @param target [String] Target element ID
        # @param html [String] HTML content to insert
        def turbo_after(target, html)
          turbo_stream(:after, target, html)
        end

        # Create multiple Turbo Stream operations
        # @yield Block that builds stream operations
        # @example
        #   turbo_streams do |s|
        #     s.append("messages", "<div>Message 1</div>")
        #     s.prepend("notifications", "<div>Alert!</div>")
        #     s.remove("loading-indicator")
        #   end
        def turbo_streams(&block)
          builder = TurboStreamBuilder.new
          block.call(builder)
          builder.render
        end

        # ===== Turbo Events =====

        # Listen for Turbo Drive events
        # @param event_name [String] Event name (without 'turbo:' prefix)
        # @yield [event] Block to execute when event fires
        # @example
        #   on_turbo("before-visit") { |e| validate_form }
        #   on_turbo("load") { init_components }
        def on_turbo(event_name, &block)
          full_name = event_name.start_with?("turbo:") ? event_name : "turbo:#{event_name}"
          `document.addEventListener(#{full_name}, function(event) { #{block.call(`event`)} })`
        end

        # Listen for turbo:before-visit - cancel navigation
        # @yield [event] Block to execute (call event.preventDefault to cancel)
        def on_turbo_before_visit(&block)
          on_turbo("before-visit", &block)
        end

        # Listen for turbo:visit - navigation started
        # @yield [event] Block to execute
        def on_turbo_visit(&block)
          on_turbo("visit", &block)
        end

        # Listen for turbo:load - page fully loaded
        # @yield [event] Block to execute
        def on_turbo_load(&block)
          on_turbo("load", &block)
        end

        # Listen for turbo:render - page rendered
        # @yield [event] Block to execute
        def on_turbo_render(&block)
          on_turbo("render", &block)
        end

        # Listen for turbo:before-fetch-request - before fetch
        # @yield [event] Block to execute
        def on_turbo_before_fetch(&block)
          on_turbo("before-fetch-request", &block)
        end

        # Listen for turbo:submit-start - form submission started
        # @yield [event] Block to execute
        def on_turbo_submit_start(&block)
          on_turbo("submit-start", &block)
        end

        # Listen for turbo:submit-end - form submission ended
        # @yield [event] Block to execute
        def on_turbo_submit_end(&block)
          on_turbo("submit-end", &block)
        end

        # Listen for turbo:frame-load - frame loaded
        # @yield [event] Block to execute
        def on_turbo_frame_load(&block)
          on_turbo("frame-load", &block)
        end

        # Listen for turbo:before-stream-render - before stream renders
        # @yield [event] Block to execute
        def on_turbo_before_stream(&block)
          on_turbo("before-stream-render", &block)
        end

        # ===== Form Helpers =====

        # Submit a form via Turbo
        # @param form_element [Native] Form element
        def turbo_submit(form_element)
          el = form_element.respond_to?(:to_n) ? form_element.to_n : form_element
          `#{el}.requestSubmit()`
        end

        # Submit a form with custom target frame
        # @param form_element [Native] Form element
        # @param frame_id [String] Target frame ID
        def turbo_submit_to_frame(form_element, frame_id)
          el = form_element.respond_to?(:to_n) ? form_element.to_n : form_element
          `#{el}.setAttribute('data-turbo-frame', #{frame_id})`
          `#{el}.requestSubmit()`
        end

        # Disable Turbo on a specific form
        # @param form_element [Native] Form element
        def disable_turbo_form(form_element)
          el = form_element.respond_to?(:to_n) ? form_element.to_n : form_element
          `#{el}.setAttribute('data-turbo', 'false')`
        end

        # Enable Turbo on a specific form
        # @param form_element [Native] Form element
        def enable_turbo_form(form_element)
          el = form_element.respond_to?(:to_n) ? form_element.to_n : form_element
          `#{el}.removeAttribute('data-turbo')`
        end

        # ===== Stream over SSE =====

        # Connect to a Turbo Stream over SSE endpoint
        # @param url [String] SSE endpoint URL
        # @return [Native] EventSource instance
        # @example
        #   source = turbo_stream_from("/notifications/stream")
        #   # Turbo will automatically process incoming streams
        def turbo_stream_from(url)
          `window.Turbo.connectStreamSource(new EventSource(#{url}))`
        end

        # Disconnect a Turbo Stream SSE source
        # @param source [Native] EventSource to disconnect
        def turbo_stream_disconnect(source)
          `window.Turbo.disconnectStreamSource(#{source})`
          `#{source}.close()`
        end

        # ===== Confirmation Dialog =====

        # Set custom Turbo confirmation handler
        # @yield [message, element, submitter] Block that returns true/false
        # @example
        #   turbo_confirm_method do |message, element, submitter|
        #     `window.confirm(message)`
        #   end
        def turbo_confirm_method(&block)
          `window.Turbo.setConfirmMethod(function(message, element, submitter) {
            return #{block.call(`message`, `element`, `submitter`)};
          })`
        end

        # ===== Morphing (Turbo 8+) =====

        # Refresh the page using Turbo's morph feature
        # @param options [Hash] Refresh options
        # @option options [Boolean] :request_id Custom request ID
        def turbo_refresh(options = {})
          if options.empty?
            `window.Turbo.visit(window.location.href, { action: 'replace' })`
          else
            native_options = options.merge(action: "replace").to_n
            `window.Turbo.visit(window.location.href, #{native_options})`
          end
        end

        # ===== Utility Methods =====

        # Check if Turbo is available
        # @return [Boolean] true if Turbo is loaded
        def turbo_available?
          `typeof window.Turbo !== 'undefined'`
        end

        # Get current Turbo Drive visit location
        # @return [String, nil] Current URL or nil
        def turbo_current_url
          `window.Turbo.navigator.location?.href`
        end

        # Cancel a pending Turbo visit
        def turbo_cancel_visit
          `window.Turbo.navigator.stop()`
        end

        # Add loading class during Turbo navigation
        # @param element [Native] Element to add class to
        # @param class_name [String] Class name to toggle
        def turbo_loading_class(element, class_name = "turbo-loading")
          el = element.respond_to?(:to_n) ? element.to_n : element

          on_turbo("before-fetch-request") { `#{el}.classList.add(#{class_name})` }
          on_turbo("before-fetch-response") { `#{el}.classList.remove(#{class_name})` }
        end
      end

      # Builder for creating multiple Turbo Stream operations
      class TurboStreamBuilder
        def initialize
          @streams = []
        end

        def append(target, html)
          @streams << %{<turbo-stream action="append" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def prepend(target, html)
          @streams << %{<turbo-stream action="prepend" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def replace(target, html)
          @streams << %{<turbo-stream action="replace" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def update(target, html)
          @streams << %{<turbo-stream action="update" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def remove(target)
          @streams << %{<turbo-stream action="remove" target="#{target}"></turbo-stream>}
        end

        def before(target, html)
          @streams << %{<turbo-stream action="before" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def after(target, html)
          @streams << %{<turbo-stream action="after" target="#{target}"><template>#{html}</template></turbo-stream>}
        end

        def render
          @streams.each do |stream_html|
            `window.Turbo.renderStreamMessage(#{stream_html})`
          end
        end
      end
    end
  end
end

# Alias for backward compatibility
TurboHelpers = OpalVite::Concerns::V1::TurboHelpers
