require 'native'

# Load helpers from opal-vite gem
require 'opal_vite/concerns/v1/react_helpers'
require 'opal_vite/concerns/v1/functional_component'

class Counter
  extend ReactHelpers

  def self.create
    div({ className: 'counter-container' },
      div({ className: 'counter-card' },
        h2(nil, 'Counter Component (Ruby + React)'),
        el(CounterComponent, nil)
      )
    )
  end
end

class CounterComponent
  extend ReactHelpers
  extend FunctionalComponent

  # React functional component with hooks - now written in pure Ruby!
  def self.to_n
    create_component do |hooks|
      count, set_count = hooks.use_state(0)

      div(nil,
        div({ className: 'counter-display' },
          div({ className: 'count-value' }, count)
        ),
        div({ className: 'counter-controls' },
          button({ className: 'btn btn-decrement', onClick: set_count.with { |c| c - 1 } }, "\u2212"),
          button({ className: 'btn btn-reset', onClick: set_count.to(0) }, 'Reset'),
          button({ className: 'btn btn-increment', onClick: set_count.with { |c| c + 1 } }, '+')
        ),
        div({ className: 'counter-info' },
          paragraph(nil, "Current count: #{count}"),
          paragraph({ className: 'status' },
            render_status(count)
          )
        )
      )
    end
  end

  def self.render_status(count)
    if count > 0
      span({ className: 'positive' }, "\u2191 Positive")
    elsif count < 0
      span({ className: 'negative' }, "\u2193 Negative")
    else
      span({ className: 'zero' }, "\u25CF Zero")
    end
  end
end
