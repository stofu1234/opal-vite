# backtick_javascript: true

# Counter controller demonstrating Stimulus Values API
# This controller showcases the new helper methods for working with Stimulus values:
# - stimulus_value(name): Get a value
# - set_stimulus_value(name, value): Set a value
# - increment_stimulus_value(name, amount): Increment a numeric value
# - decrement_stimulus_value(name, amount): Decrement a numeric value
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define Stimulus values and targets using Ruby DSL
  # The count value is a Number type that will be automatically converted
  self.values = { count: :number }
  self.targets = ["display"]

  def connect
    puts "Counter controller connected!"
    update_display
  end

  # Increment the counter using the increment_stimulus_value helper
  def increment
    increment_stimulus_value(:count)
    # Note: update_display is called automatically via count_value_changed callback
  end

  # Decrement the counter using the decrement_stimulus_value helper
  def decrement
    decrement_stimulus_value(:count)
    # Note: update_display is called automatically via count_value_changed callback
  end

  # Reset the counter to 0 using the set_stimulus_value helper
  def reset
    set_stimulus_value(:count, 0)
    # Note: update_display is called automatically via count_value_changed callback
  end

  private

  # Update the display target with the current count value
  def update_display
    return unless has_target?(:display)

    current_count = stimulus_value(:count)
    target_set_text(:display, current_count.to_s)

    # Add a brief animation class for visual feedback
    display_element = get_target(:display)
    add_class(display_element, 'changed')

    set_timeout(300) do
      remove_class(display_element, 'changed')
    end
  end

  # Stimulus Values API callback - automatically called when count value changes
  # This method name follows the pattern: {valueName}ValueChanged
  def count_value_changed
    current_count = stimulus_value(:count)
    puts "Count changed to: #{current_count}"
    update_display
  end
end
