# backtick_javascript: true
require 'native'

# Load ReactHelpers from opal-vite gem
require 'opal_vite/concerns/react_helpers'

class Counter
  extend ReactHelpers

  def self.create
    r = react

    r.createElement('div', { className: 'counter-container' },
      r.createElement('div', { className: 'counter-card' },
        r.createElement('h2', nil, 'Counter Component (Ruby + React)'),
        r.createElement(CounterComponent, nil)
      )
    )
  end
end

class CounterComponent
  extend ReactHelpers

  # React functional component with hooks
  # Note: React hooks (useState) require JavaScript function context,
  # so this part must remain as backtick JavaScript
  def self.to_n
    r = react

    `function() {
      const [count, setCount] = #{r}.useState(0);

      const increment = () => setCount(count + 1);
      const decrement = () => setCount(count - 1);
      const reset = () => setCount(0);

      return #{r}.createElement('div', null,
        #{r}.createElement('div', { className: 'counter-display' },
          #{r}.createElement('div', { className: 'count-value' }, count)
        ),
        #{r}.createElement('div', { className: 'counter-controls' },
          #{r}.createElement('button',
            { className: 'btn btn-decrement', onClick: decrement },
            '−'
          ),
          #{r}.createElement('button',
            { className: 'btn btn-reset', onClick: reset },
            'Reset'
          ),
          #{r}.createElement('button',
            { className: 'btn btn-increment', onClick: increment },
            '+'
          )
        ),
        #{r}.createElement('div', { className: 'counter-info' },
          #{r}.createElement('p', null, 'Current count: ' + count),
          #{r}.createElement('p', { className: 'status' },
            count > 0 ? #{r}.createElement('span', { className: 'positive' }, '↑ Positive') :
            count < 0 ? #{r}.createElement('span', { className: 'negative' }, '↓ Negative') :
            #{r}.createElement('span', { className: 'zero' }, '● Zero')
          )
        )
      );
    }`
  end
end
