# backtick_javascript: true

# Tabs controller with accessible tab switching
# Uses aria attributes for accessibility
class TabsController < StimulusController
  include StimulusHelpers

  self.targets = ["tab", "panel"]
  self.values = { index: :number }

  def initialize
    super
    @index_value = 0
  end

  def connect
    puts "Tabs controller connected!"
    show_tab(@index_value)
  end

  def select
    index = action_param_int(:index)
    self.index_value = index
  end

  private

  def index_value_changed
    show_tab(index_value)
  end

  def show_tab(index)
    tabs = js_prop(:tabTargets)
    panels = js_prop(:panelTargets)

    js_each(tabs) do |tab, i|
      if `#{i} === #{index}`
        add_class(tab, 'tabs-tab--active')
        set_attr(tab, 'aria-selected', 'true')
        set_attr(tab, 'tabindex', '0')
      else
        remove_class(tab, 'tabs-tab--active')
        set_attr(tab, 'aria-selected', 'false')
        set_attr(tab, 'tabindex', '-1')
      end
    end

    js_each(panels) do |panel, i|
      if `#{i} === #{index}`
        add_class(panel, 'tabs-panel--active')
        set_attr(panel, 'aria-hidden', 'false')
      else
        remove_class(panel, 'tabs-panel--active')
        set_attr(panel, 'aria-hidden', 'true')
      end
    end
  end
end
