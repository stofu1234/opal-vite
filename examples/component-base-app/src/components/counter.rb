# backtick_javascript: true

require 'opal_vite/concerns/v1/component'

# A stateful counter built on the framework-agnostic OpalComponent base class.
# No React/Vue/Stimulus — just state + render + DOM events.
class Counter < OpalComponent
  def initial_state
    { count: 0 }
  end

  def render
    <<~HTML
      <div class="counter">
        <h2>OpalComponent Counter</h2>
        <p class="count">#{state[:count]}</p>
        <button data-act="dec">−</button>
        <button data-act="reset">Reset</button>
        <button data-act="inc">+</button>
      </div>
    HTML
  end

  def after_render
    on('[data-act="inc"]', 'click') { set_state(count: state[:count] + 1) }
    on('[data-act="dec"]', 'click') { set_state(count: state[:count] - 1) }
    on('[data-act="reset"]', 'click') { set_state(count: 0) }
  end
end
