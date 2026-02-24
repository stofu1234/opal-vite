# backtick_javascript: true

# Toggle controller for ON/OFF switches
# Supports multiple toggle variants via action params
class ToggleController < StimulusController
  include StimulusHelpers

  self.targets = ["switch", "status", "content"]
  self.values = { on: :boolean, label_on: :string, label_off: :string }
  self.classes = ["active"]

  def connect
    puts "Toggle controller connected!"
    update_display
  end

  def toggle
    current = stimulus_value(:on)
    set_stimulus_value(:on, !current)
  end

  def on_value_changed(*_)
    update_display
  end

  private

  def update_display
    sw = get_target(:switch)
    return unless sw

    on = stimulus_value(:on)

    if on
      add_class(sw, 'toggle-switch--on')
      label = stimulus_value(:label_on)
      label = 'ON' if !label || `#{label}.length === 0`
      target_set_text(:status, label) if has_target?(:status)
      set_target_style(:content, 'display', 'block') if has_target?(:content)
    else
      remove_class(sw, 'toggle-switch--on')
      label = stimulus_value(:label_off)
      label = 'OFF' if !label || `#{label}.length === 0`
      target_set_text(:status, label) if has_target?(:status)
      set_target_style(:content, 'display', 'none') if has_target?(:content)
    end
  end
end
