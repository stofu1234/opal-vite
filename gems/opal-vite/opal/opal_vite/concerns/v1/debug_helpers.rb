# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # DebugHelpers concern - provides debugging utilities for Opal applications
      # Outputs structured debug information to browser console
      module DebugHelpers
        # Log a debug message with optional data
        # @param message [String] The message to log
        # @param data [Object] Optional data to include
        def debug_log(message, data = nil)
          return unless debug_enabled?

          if data
            `console.log('[DEBUG] ' + #{message}, #{data.to_n})`
          else
            `console.log('[DEBUG] ' + #{message})`
          end
        end

        # Log a warning message
        # @param message [String] The warning message
        # @param data [Object] Optional data to include
        def debug_warn(message, data = nil)
          return unless debug_enabled?

          if data
            `console.warn('[WARN] ' + #{message}, #{data.to_n})`
          else
            `console.warn('[WARN] ' + #{message})`
          end
        end

        # Log an error message
        # @param message [String] The error message
        # @param error [Object] Optional error object or data
        def debug_error(message, error = nil)
          if error
            `console.error('[ERROR] ' + #{message}, #{error.to_n})`
          else
            `console.error('[ERROR] ' + #{message})`
          end
        end

        # Log a group of related debug messages
        # @param label [String] Group label
        # @yield Block containing debug_log calls
        def debug_group(label)
          return yield unless debug_enabled?

          `console.group('[DEBUG] ' + #{label})`
          yield
          `console.groupEnd()`
        end

        # Log a collapsed group of related debug messages
        # @param label [String] Group label
        # @yield Block containing debug_log calls
        def debug_group_collapsed(label)
          return yield unless debug_enabled?

          `console.groupCollapsed('[DEBUG] ' + #{label})`
          yield
          `console.groupEnd()`
        end

        # Start a performance timer
        # @param label [String] Timer label
        def debug_time(label)
          return unless debug_enabled?
          `console.time('[TIMER] ' + #{label})`
        end

        # End a performance timer and log the elapsed time
        # @param label [String] Timer label (must match the one used in debug_time)
        def debug_time_end(label)
          return unless debug_enabled?
          `console.timeEnd('[TIMER] ' + #{label})`
        end

        # Log a table of data (useful for arrays/objects)
        # @param data [Array, Hash] Data to display as table
        def debug_table(data)
          return unless debug_enabled?
          `console.table(#{data.to_n})`
        end

        # Log object inspection with Ruby-style formatting
        # @param obj [Object] Object to inspect
        # @param label [String] Optional label
        def debug_inspect(obj, label = nil)
          return unless debug_enabled?

          inspected = obj.inspect
          if label
            `console.log('[INSPECT] ' + #{label} + ':', #{inspected})`
          else
            `console.log('[INSPECT]', #{inspected})`
          end
        end

        # Log the current call stack
        # @param message [String] Optional message
        def debug_trace(message = nil)
          return unless debug_enabled?

          if message
            `console.trace('[TRACE] ' + #{message})`
          else
            `console.trace('[TRACE]')`
          end
        end

        # Assert a condition and log error if false
        # @param condition [Boolean] Condition to check
        # @param message [String] Message to show if assertion fails
        def debug_assert(condition, message = 'Assertion failed')
          `console.assert(#{condition}, '[ASSERT] ' + #{message})`
        end

        # Count and log how many times this is called with the given label
        # @param label [String] Counter label
        def debug_count(label = 'default')
          return unless debug_enabled?
          `console.count('[COUNT] ' + #{label})`
        end

        # Reset the counter for the given label
        # @param label [String] Counter label
        def debug_count_reset(label = 'default')
          return unless debug_enabled?
          `console.countReset('[COUNT] ' + #{label})`
        end

        # Check if debugging is enabled
        # Override this method to control debug output
        # @return [Boolean] true if debugging is enabled
        def debug_enabled?
          # Check for debug flag in multiple places
          return @debug_enabled unless @debug_enabled.nil?

          # Check window.OPAL_DEBUG or localStorage debug setting
          @debug_enabled = `
            (typeof window !== 'undefined' &&
              (window.OPAL_DEBUG === true ||
               (typeof localStorage !== 'undefined' &&
                localStorage.getItem('opal_debug') === 'true')))
          `
        end

        # Enable debugging
        def debug_enable!
          @debug_enabled = true
          `
            if (typeof window !== 'undefined') {
              window.OPAL_DEBUG = true;
              if (typeof localStorage !== 'undefined') {
                localStorage.setItem('opal_debug', 'true');
              }
            }
          `
          debug_log('Debug mode enabled')
        end

        # Disable debugging
        def debug_disable!
          debug_log('Debug mode disabled')
          @debug_enabled = false
          `
            if (typeof window !== 'undefined') {
              window.OPAL_DEBUG = false;
              if (typeof localStorage !== 'undefined') {
                localStorage.removeItem('opal_debug');
              }
            }
          `
        end

        # Measure execution time of a block
        # @param label [String] Label for the measurement
        # @yield Block to measure
        # @return [Object] Return value of the block
        def debug_measure(label)
          return yield unless debug_enabled?

          start_time = `performance.now()`
          result = yield
          end_time = `performance.now()`
          duration = end_time - start_time

          `console.log('[PERF] ' + #{label} + ': ' + #{duration.round(2)} + 'ms')`
          result
        end

        # Log Stimulus controller connection info
        # @param controller [Object] Stimulus controller instance
        def debug_stimulus_connect(controller = nil)
          return unless debug_enabled?

          ctrl = controller || self
          name = ctrl.class.respond_to?(:stimulus_name) ? ctrl.class.stimulus_name : ctrl.class.name
          `console.log('[STIMULUS] Connected:', #{name})`
        end

        # Log Stimulus controller disconnection info
        # @param controller [Object] Stimulus controller instance
        def debug_stimulus_disconnect(controller = nil)
          return unless debug_enabled?

          ctrl = controller || self
          name = ctrl.class.respond_to?(:stimulus_name) ? ctrl.class.stimulus_name : ctrl.class.name
          `console.log('[STIMULUS] Disconnected:', #{name})`
        end

        # Log Stimulus action info
        # @param action_name [String] Name of the action
        # @param event [Object] Event object
        def debug_stimulus_action(action_name, event = nil)
          return unless debug_enabled?

          if event
            `console.log('[STIMULUS] Action:', #{action_name}, 'Event:', #{event.to_n})`
          else
            `console.log('[STIMULUS] Action:', #{action_name})`
          end
        end
      end
    end
  end
end

# Alias for backward compatibility
DebugHelpers = OpalVite::Concerns::V1::DebugHelpers
