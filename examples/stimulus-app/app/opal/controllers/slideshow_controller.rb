# backtick_javascript: true

# Slideshow controller demonstrating CSS classes and state management
class SlideshowController < StimulusController
  include StimulusHelpers

  self.targets = ["slide"]
  self.classes = ["active"]
  self.values = { index: :number }

  def initialize
    super
    @index_value = 0
  end

  def connect
    show_current_slide
  end

  def next
    slides = js_prop(:slideTargets)
    length = js_length(slides)
    self.index_value = (index_value + 1) % length
  end

  def previous
    slides = js_prop(:slideTargets)
    length = js_length(slides)
    self.index_value = (index_value - 1) % length
  end

  private

  def show_current_slide
    current_index = index_value
    active_classes = js_prop(:activeClasses) || ['active']
    slides = js_prop(:slideTargets)

    js_each(slides) do |slide, index|
      class_list = js_get(slide, :classList)
      if `#{index} === #{current_index}`
        js_call_on(class_list, :add, *active_classes)
      else
        js_call_on(class_list, :remove, *active_classes)
      end
    end
  end

  def index_value_changed
    show_current_slide
  end
end
