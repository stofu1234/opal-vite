# backtick_javascript: true

# TabsController - Manages tab button selection and panel coordination
#
# This controller demonstrates:
# - Stimulus Outlets API for connecting to panel controllers
# - stimulus_dispatch() for emitting custom events
# - Using StimulusHelpers for outlet management
#
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define outlets to connect with panel controllers
  # This allows the tabs controller to access all panel controller instances
  self.outlets = ["panel"]

  def initialize
    super
    @current_index = 0
  end

  def connect
    puts "TabsController connected"

    # Log outlet information
    if has_outlet?(:panel)
      panel_count = get_outlets(:panel).length
      puts "Found #{panel_count} panel outlets"
    else
      puts "No panel outlets found"
    end

    # Show the first panel on load
    show_panel_by_index(0)
  end

  # Action: Select a tab
  # Called when a tab button is clicked
  def select
    # Get the index from action parameters
    index = action_param_int(:index, 0)

    puts "Selecting tab #{index}"

    # Update active tab button styling
    update_tab_buttons(index)

    # Show the selected panel
    show_panel_by_index(index)

    # Store current index
    @current_index = index
  end

  private

  # Update tab button styling to show which is active
  def update_tab_buttons(active_index)
    buttons = query_all_element('.tab-button')

    buttons.each_with_index do |button, index|
      if index == active_index
        add_class(button, 'tab-active')
      else
        remove_class(button, 'tab-active')
      end
    end
  end

  # Show panel by index using both outlets and events
  def show_panel_by_index(index)
    # Method 1: Use outlets to call hide on all panels
    # This demonstrates the call_all_outlets helper
    if has_outlet?(:panel)
      puts "Hiding all panels via outlets"
      call_all_outlets(:panel, :hide)
    end

    # Method 2: Dispatch custom event for the selected panel
    # Using dispatch_window_event since panels listen on window
    # This demonstrates loose coupling via window events
    puts "Dispatching tabs:change event for index #{index}"
    dispatch_window_event('tabs:change', { index: index })
  end

  # Alternative method: Show panel using outlet reference directly
  # This demonstrates get_outlets and iteration
  def show_panel_via_outlets(index)
    panels = get_outlets(:panel)

    panels.each do |panel|
      # Get the panel's index value
      panel_index = js_get(panel, 'indexValue')

      if js_equals?(panel_index, index)
        # Call show method on the panel controller
        js_call_on(panel, :show)
      else
        # Call hide method on the panel controller
        js_call_on(panel, :hide)
      end
    end
  end
end
