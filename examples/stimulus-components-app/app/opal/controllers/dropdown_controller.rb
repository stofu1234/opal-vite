# backtick_javascript: true

# Dropdown controller with click-to-toggle menu
# Closes when clicking outside the dropdown
class DropdownController < StimulusController
  include StimulusHelpers

  self.targets = ["menu", "button"]
  self.values = { open: :boolean }

  def initialize
    super
    @outside_click_handler = nil
  end

  def connect
    @outside_click_handler = proc { |event| handle_outside_click(event) }
    `document.addEventListener('click', #{@outside_click_handler})`
  end

  def disconnect
    return unless @outside_click_handler
    `document.removeEventListener('click', #{@outside_click_handler})`
  end

  def toggle
    self.open_value = !open_value
  end

  def close
    self.open_value = false
  end

  private

  def open_value_changed
    menu = get_target(:menu)
    return unless menu

    if open_value
      add_class(menu, 'dropdown-menu--open')
    else
      remove_class(menu, 'dropdown-menu--open')
    end
  end

  def handle_outside_click(event)
    return unless open_value

    el = this_element
    target = `#{event}.target`
    contains = `#{el}.contains(#{target})`

    unless contains
      self.open_value = false
    end
  end
end
