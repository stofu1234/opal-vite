# backtick_javascript: true

# Tooltip controller with hover-triggered tooltips
# Supports 4 positions: top, bottom, left, right
class TooltipController < StimulusController
  include StimulusHelpers

  self.values = { text: :string, position: :string, delay: :number }

  def initialize
    super
    @text_value = 'Tooltip'
    @position_value = 'top'
    @delay_value = 0
    @tooltip_el = nil
    @show_timer = nil
  end

  def connect
  end

  def disconnect
    remove_tooltip
  end

  def show
    delay = delay_value
    if delay > 0
      @show_timer = set_timeout(delay) do
        create_tooltip
      end
    else
      create_tooltip
    end
  end

  def hide
    if @show_timer
      clear_timeout(@show_timer)
      @show_timer = nil
    end
    remove_tooltip
  end

  private

  def create_tooltip
    return if @tooltip_el

    @tooltip_el = create_element(:div)
    add_class(@tooltip_el, 'tooltip')
    add_class(@tooltip_el, "tooltip--#{position_value}")
    set_text(@tooltip_el, text_value)

    el = this_element
    append_child(el, @tooltip_el)
  end

  def remove_tooltip
    if @tooltip_el
      remove_element(@tooltip_el)
      @tooltip_el = nil
    end
  end
end
