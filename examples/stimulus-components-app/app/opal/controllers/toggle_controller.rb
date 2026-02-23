# backtick_javascript: true

# Toggle controller for ON/OFF switches
# Supports multiple toggle variants via action params
class ToggleController < StimulusController
  include StimulusHelpers

  self.targets = ["switch", "status", "content"]
  self.values = { on: :boolean, label_on: :string, label_off: :string }
  self.classes = ["active"]

  def initialize
    super
    @on_value = false
    @label_on_value = 'ON'
    @label_off_value = 'OFF'
  end

  def connect
    puts "Toggle controller connected!"
    update_display
  end

  def toggle
    self.on_value = !on_value
  end

  private

  def on_value_changed
    update_display
  end

  def update_display
    switch_el = get_target(:switch)
    return unless switch_el

    active_classes = js_prop(:activeClasses) || ['toggle-switch--on']

    if on_value
      class_list = js_get(switch_el, :classList)
      js_call_on(class_list, :add, *active_classes)
      update_status(label_on_value)
      show_content
    else
      class_list = js_get(switch_el, :classList)
      js_call_on(class_list, :remove, *active_classes)
      update_status(label_off_value)
      hide_content
    end
  end

  def update_status(text)
    if has_target?(:status)
      target_set_text(:status, text)
    end
  end

  def show_content
    if has_target?(:content)
      content = get_target(:content)
      set_style(content, :display, 'block')
    end
  end

  def hide_content
    if has_target?(:content)
      content = get_target(:content)
      set_style(content, :display, 'none')
    end
  end
end
