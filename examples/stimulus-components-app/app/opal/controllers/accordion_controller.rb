# backtick_javascript: true

# Accordion controller with expandable/collapsible panels
# Supports Expand All / Collapse All via action params
class AccordionController < StimulusController
  include StimulusHelpers

  self.targets = ["item", "content", "icon"]
  self.values = { allow_multiple: :boolean }

  def connect
    puts "Accordion controller connected!"
  end

  def toggle
    index = action_param_int(:index)
    items = js_prop(:contentTargets)
    icons = js_prop(:iconTargets)
    item = js_array_at(items, index)
    icon = js_array_at(icons, index)

    return unless item

    is_open = has_class?(item, 'accordion-content--open')

    unless allow_multiple_value
      close_all_items
    end

    if is_open
      remove_class(item, 'accordion-content--open')
      set_text(icon, '+') if icon
    else
      add_class(item, 'accordion-content--open')
      set_text(icon, "\u2212") if icon
    end
  end

  def expand_all
    items = js_prop(:contentTargets)
    icons = js_prop(:iconTargets)

    js_each(items) do |item, _index|
      add_class(item, 'accordion-content--open')
    end

    js_each(icons) do |icon, _index|
      set_text(icon, "\u2212")
    end
  end

  def collapse_all
    close_all_items
  end

  private

  def close_all_items
    items = js_prop(:contentTargets)
    icons = js_prop(:iconTargets)

    js_each(items) do |item, _index|
      remove_class(item, 'accordion-content--open')
    end

    js_each(icons) do |icon, _index|
      set_text(icon, '+')
    end
  end
end
