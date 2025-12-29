# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # ActionCableHelpers - Ruby-friendly DSL for ActionCable WebSocket communication
      #
      # This module provides methods for connecting to and interacting with
      # Rails ActionCable channels from Opal/Stimulus controllers.
      #
      # Prerequisites:
      # - @rails/actioncable package must be installed (npm install @rails/actioncable)
      # - ActionCable consumer must be imported in your JavaScript entry point
      #
      # Usage:
      #   # In your main.js:
      #   import { createConsumer } from "@rails/actioncable"
      #   window.ActionCable = { createConsumer }
      #
      #   # In your Opal controller:
      #   class ChatController < StimulusController
      #     include OpalVite::Concerns::V1::ActionCableHelpers
      #
      #     def connect
      #       cable_connect("/cable")
      #       subscribe_to("ChatChannel", room_id: 1) do |subscription|
      #         on_cable_received(subscription) do |data|
      #           append_message(data)
      #         end
      #       end
      #     end
      #
      #     def disconnect
      #       cable_disconnect
      #     end
      #
      #     def send_message
      #       cable_perform(:speak, message: target_value(:input))
      #     end
      #   end
      module ActionCableHelpers
        # ===== Consumer Management =====

        # Create and store an ActionCable consumer
        # @param url [String] WebSocket URL (e.g., "/cable" or "wss://example.com/cable")
        # @return [Native] ActionCable consumer instance
        # @example
        #   cable_connect("/cable")
        #   cable_connect("wss://api.example.com/cable")
        def cable_connect(url = "/cable")
          @_cable_consumer = `window.ActionCable.createConsumer(#{url})`
        end

        # Get the current ActionCable consumer
        # @return [Native, nil] Consumer instance or nil
        def cable_consumer
          @_cable_consumer
        end

        # Disconnect and cleanup the ActionCable consumer
        def cable_disconnect
          return unless @_cable_consumer
          `#{@_cable_consumer}.disconnect()`
          @_cable_subscriptions = nil
          @_cable_consumer = nil
        end

        # Check if ActionCable is connected
        # @return [Boolean] true if connected
        def cable_connected?
          return false unless @_cable_consumer
          `#{@_cable_consumer}.connection.isOpen()`
        end

        # ===== Subscription Management =====

        # Subscribe to an ActionCable channel
        # @param channel_name [String] Channel class name (e.g., "ChatChannel")
        # @param params [Hash] Channel parameters (e.g., room_id: 1)
        # @yield [subscription] Block that receives the subscription for setup
        # @return [Native] Subscription instance
        # @example
        #   subscribe_to("ChatChannel", room_id: 1) do |subscription|
        #     on_cable_connected(subscription) { puts "Connected!" }
        #     on_cable_received(subscription) { |data| handle_data(data) }
        #   end
        def subscribe_to(channel_name, params = {}, &setup_block)
          raise "Cable not connected. Call cable_connect first." unless @_cable_consumer

          @_cable_subscriptions ||= {}
          subscription_params = { channel: channel_name }.merge(params)
          native_params = subscription_params.to_n

          # Create subscription with empty callbacks (will be set via helpers)
          subscription = `#{@_cable_consumer}.subscriptions.create(#{native_params}, {
            connected: function() {},
            disconnected: function() {},
            received: function(data) {},
            rejected: function() {}
          })`

          # Store subscription with a key
          key = cable_subscription_key(channel_name, params)
          @_cable_subscriptions[key] = subscription

          # Yield for setting up callbacks
          setup_block.call(subscription) if setup_block

          subscription
        end

        # Unsubscribe from a channel
        # @param channel_name [String] Channel class name
        # @param params [Hash] Channel parameters
        def unsubscribe_from(channel_name, params = {})
          return unless @_cable_subscriptions
          key = cable_subscription_key(channel_name, params)
          subscription = @_cable_subscriptions.delete(key)
          `#{subscription}.unsubscribe()` if subscription
        end

        # Get a subscription by channel name and params
        # @param channel_name [String] Channel class name
        # @param params [Hash] Channel parameters
        # @return [Native, nil] Subscription instance or nil
        def get_subscription(channel_name, params = {})
          return nil unless @_cable_subscriptions
          key = cable_subscription_key(channel_name, params)
          @_cable_subscriptions[key]
        end

        # ===== Subscription Callbacks =====

        # Set the connected callback for a subscription
        # @param subscription [Native] Subscription instance
        # @yield Block to execute when connected
        def on_cable_connected(subscription, &block)
          `#{subscription}.connected = function() { #{block.call} }`
        end

        # Set the disconnected callback for a subscription
        # @param subscription [Native] Subscription instance
        # @yield Block to execute when disconnected
        def on_cable_disconnected(subscription, &block)
          `#{subscription}.disconnected = function() { #{block.call} }`
        end

        # Set the received callback for a subscription
        # @param subscription [Native] Subscription instance
        # @yield [data] Block that receives incoming data
        def on_cable_received(subscription, &block)
          `#{subscription}.received = function(data) { #{block.call(`data`)} }`
        end

        # Set the rejected callback for a subscription
        # @param subscription [Native] Subscription instance
        # @yield Block to execute when subscription is rejected
        def on_cable_rejected(subscription, &block)
          `#{subscription}.rejected = function() { #{block.call} }`
        end

        # ===== Sending Data =====

        # Perform an action on the default/first subscription
        # @param action [Symbol, String] Action name (server-side method)
        # @param data [Hash] Data to send
        # @example
        #   cable_perform(:speak, message: "Hello!")
        #   cable_perform(:typing, user_id: current_user_id)
        def cable_perform(action, data = {})
          subscription = default_subscription
          raise "No active subscription" unless subscription
          perform_on(subscription, action, data)
        end

        # Perform an action on a specific subscription
        # @param subscription [Native] Subscription instance
        # @param action [Symbol, String] Action name
        # @param data [Hash] Data to send
        def perform_on(subscription, action, data = {})
          native_data = data.to_n
          `#{subscription}.perform(#{action.to_s}, #{native_data})`
        end

        # Send raw data on a subscription
        # @param subscription [Native] Subscription instance
        # @param data [Hash] Data to send
        def cable_send(subscription, data)
          native_data = data.to_n
          `#{subscription}.send(#{native_data})`
        end

        # ===== Convenience Methods =====

        # Subscribe and setup all callbacks in one call
        # @param channel_name [String] Channel class name
        # @param params [Hash] Channel parameters
        # @param on_connected [Proc] Connected callback
        # @param on_disconnected [Proc] Disconnected callback
        # @param on_received [Proc] Received callback (receives data)
        # @param on_rejected [Proc] Rejected callback
        # @return [Native] Subscription instance
        def cable_subscribe(channel_name, params: {}, on_connected: nil, on_disconnected: nil, on_received: nil, on_rejected: nil)
          raise "Cable not connected. Call cable_connect first." unless @_cable_consumer

          @_cable_subscriptions ||= {}
          subscription_params = { channel: channel_name }.merge(params)
          native_params = subscription_params.to_n

          # Create subscription with callbacks directly
          subscription = `#{@_cable_consumer}.subscriptions.create(#{native_params}, {
            connected: function() {
              #{on_connected.call if on_connected}
            },
            disconnected: function() {
              #{on_disconnected.call if on_disconnected}
            },
            received: function(data) {
              #{on_received.call(`data`) if on_received}
            },
            rejected: function() {
              #{on_rejected.call if on_rejected}
            }
          })`

          # Store subscription with a key
          key = cable_subscription_key(channel_name, params)
          @_cable_subscriptions[key] = subscription

          subscription
        end

        # Quick subscription setup for simple channels
        # @param channel_name [String] Channel class name
        # @param params [Hash] Channel parameters
        # @yield [data] Block that handles received data
        # @return [Native] Subscription instance
        # @example
        #   quick_subscribe("NotificationChannel") do |data|
        #     show_notification(data["message"])
        #   end
        def quick_subscribe(channel_name, params = {}, &on_received)
          subscribe_to(channel_name, params) do |subscription|
            on_cable_received(subscription) { |data| on_received.call(data) } if on_received
          end
        end

        # ===== Broadcast Helpers =====
        # These methods help handle specific broadcast patterns

        # Handle a broadcast that contains HTML to insert
        # @param data [Native] Received data object
        # @param target_selector [String] CSS selector for target element
        # @param position [Symbol] Insert position (:append, :prepend, :replace, :before, :after)
        def handle_html_broadcast(data, target_selector, position = :append)
          html = `#{data}.html || #{data}.content || #{data}.body || ""`
          return if `#{html} === ""`

          target = `document.querySelector(#{target_selector})`
          return unless `#{target}`

          case position
          when :append
            `#{target}.insertAdjacentHTML('beforeend', #{html})`
          when :prepend
            `#{target}.insertAdjacentHTML('afterbegin', #{html})`
          when :replace
            `#{target}.innerHTML = #{html}`
          when :before
            `#{target}.insertAdjacentHTML('beforebegin', #{html})`
          when :after
            `#{target}.insertAdjacentHTML('afterend', #{html})`
          end
        end

        # Handle a broadcast that updates a specific element
        # @param data [Native] Received data with id and content
        # @param id_key [String] Key in data containing element ID
        # @param content_key [String] Key in data containing new content
        def handle_update_broadcast(data, id_key = "id", content_key = "content")
          element_id = `#{data}[#{id_key}]`
          content = `#{data}[#{content_key}]`
          return if `#{element_id} === undefined || #{content} === undefined`

          element = `document.getElementById(#{element_id})`
          `#{element}.innerHTML = #{content}` if `#{element}`
        end

        # Handle a broadcast that removes an element
        # @param data [Native] Received data with id
        # @param id_key [String] Key in data containing element ID
        def handle_remove_broadcast(data, id_key = "id")
          element_id = `#{data}[#{id_key}]`
          return if `#{element_id} === undefined`

          element = `document.getElementById(#{element_id})`
          `#{element}.remove()` if `#{element}`
        end

        # ===== Data Extraction Helpers =====

        # Extract a value from received ActionCable data
        # @param data [Native] Received data object
        # @param key [String, Symbol] Key to extract
        # @param default [Object] Default value if key doesn't exist
        # @return [Object] Extracted value or default
        def cable_data(data, key, default = nil)
          key_s = key.to_s
          value = `#{data}[#{key_s}]`
          `#{value} === undefined` ? default : value
        end

        # Extract and parse a JSON string from received data
        # @param data [Native] Received data object
        # @param key [String, Symbol] Key containing JSON string
        # @return [Native] Parsed JSON object or nil
        def cable_data_json(data, key)
          json_str = cable_data(data, key)
          return nil if json_str.nil?
          `JSON.parse(#{json_str})`
        rescue
          nil
        end

        # Check if received data has a specific key
        # @param data [Native] Received data object
        # @param key [String, Symbol] Key to check
        # @return [Boolean] true if key exists
        def cable_data_has?(data, key)
          key_s = key.to_s
          `#{data}.hasOwnProperty(#{key_s})`
        end

        # Get data type from received data (for routing actions)
        # @param data [Native] Received data object
        # @param type_key [String] Key containing type/action name
        # @return [String, nil] Type value
        def cable_data_type(data, type_key = "type")
          cable_data(data, type_key)
        end

        # Route incoming data based on type/action
        # @param data [Native] Received data object
        # @param handlers [Hash] Map of type => handler proc
        # @param type_key [String] Key containing type/action name
        # @example
        #   on_cable_received(subscription) do |data|
        #     cable_route(data, {
        #       "message" => -> { handle_message(data) },
        #       "typing" => -> { handle_typing(data) },
        #       "presence" => -> { handle_presence(data) }
        #     })
        #   end
        def cable_route(data, handlers, type_key = "type")
          data_type = cable_data_type(data, type_key)
          return unless data_type
          handler = handlers[data_type] || handlers[data_type.to_sym]
          handler&.call
        end

        private

        # Generate a unique key for subscription storage
        def cable_subscription_key(channel_name, params)
          "#{channel_name}:#{params.to_a.sort.map { |k, v| "#{k}=#{v}" }.join(',')}"
        end

        # Get the default (first) subscription
        def default_subscription
          return nil unless @_cable_subscriptions
          @_cable_subscriptions.values.first
        end
      end
    end
  end
end

# Alias for backward compatibility
ActionCableHelpers = OpalVite::Concerns::V1::ActionCableHelpers
