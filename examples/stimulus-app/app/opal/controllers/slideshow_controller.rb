# backtick_javascript: true

# Slideshow controller demonstrating CSS classes and state management
class SlideshowController < StimulusController
  include JsProxyEx

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
    length = `this.slideTargets.length`
    self.index_value = (index_value + 1) % length
  end

  def previous
    length = `this.slideTargets.length`
    self.index_value = (index_value - 1) % length
  end

  private

  def show_current_slide
    current_index = index_value
    `
      const activeClasses = this.activeClasses || ['active'];
      this.slideTargets.forEach(function(slide, index) {
        if (index === #{current_index}) {
          slide.classList.add(...activeClasses);
        } else {
          slide.classList.remove(...activeClasses);
        }
      });
    `
  end

  def index_value_changed
    show_current_slide
  end
end
