# Slideshow controller demonstrating CSS classes and state management
class SlideshowController < StimulusController
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
    self.index_value = (index_value + 1) % slide_targets.length
  end

  def previous
    self.index_value = (index_value - 1) % slide_targets.length
  end

  private

  def show_current_slide
    slide_targets.each_with_index do |slide, index|
      if index == index_value
        slide.class_list.add(*active_classes)
      else
        slide.class_list.remove(*active_classes)
      end
    end
  end

  def index_value_changed
    show_current_slide
  end
end
