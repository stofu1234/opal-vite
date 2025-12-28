# backtick_javascript: true

# PanelController - Manages individual tab panel visibility and animations
#
# This controller demonstrates:
# - Listening to custom events dispatched by other controllers
# - Using Stimulus values to store panel index
# - Show/hide methods callable via outlets
# - CSS class manipulation for animations
#
class PanelController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define Stimulus values
  # index: stores which panel this is (0, 1, 2, etc.)
  self.values = { index: :number }

  def connect
    panel_index = stimulus_value(:index)
    puts "PanelController connected - Panel #{panel_index}"

    # Listen for tabs:change events dispatched by TabsController
    # This demonstrates event-based inter-controller communication
    on_window_event('tabs:change') do |event|
      handle_change(event)
    end
  end

  # Show this panel with animation
  # This method can be called via outlets or internally
  def show
    panel_index = stimulus_value(:index)
    puts "Showing panel #{panel_index}"

    # Remove hidden class and add visible class for animation
    element_remove_class('panel-hidden')
    element_add_class('panel-visible')
  end

  # Hide this panel
  # This method can be called via outlets or internally
  def hide
    panel_index = stimulus_value(:index)
    puts "Hiding panel #{panel_index}"

    # Remove visible class and add hidden class
    element_remove_class('panel-visible')
    element_add_class('panel-hidden')
  end

  private

  # Handle the tabs:change event
  # Compares the event's index with this panel's index
  def handle_change(event)
    # Get the selected index from event detail
    detail = `#{event}.detail`
    selected_index = `#{detail}.index`

    # Get this panel's index
    panel_index = stimulus_value(:index)

    puts "Panel #{panel_index} received tabs:change event with index #{selected_index}"

    # Show this panel if indices match, hide otherwise
    if js_equals?(selected_index, panel_index)
      show
    else
      hide
    end
  end
end
