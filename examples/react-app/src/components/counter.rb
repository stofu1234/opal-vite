# backtick_javascript: true
require 'native'

# Load ReactHelpers from opal-vite gem
require 'opal_vite/concerns/v1/react_helpers'

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

    `(function(React) {
      return function() {
        const [count, setCount] = React.useState(0);

        const increment = () => setCount(count + 1);
        const decrement = () => setCount(count - 1);
        const reset = () => setCount(0);

        return React.createElement('div', null,
          React.createElement('div', { className: 'counter-display' },
            React.createElement('div', { className: 'count-value' }, count)
          ),
          React.createElement('div', { className: 'counter-controls' },
            React.createElement('button',
              { className: 'btn btn-decrement', onClick: decrement },
              '−'
            ),
            React.createElement('button',
              { className: 'btn btn-reset', onClick: reset },
              'Reset'
            ),
            React.createElement('button',
              { className: 'btn btn-increment', onClick: increment },
              '+'
            )
          ),
          React.createElement('div', { className: 'counter-info' },
            React.createElement('p', null, 'Current count: ' + count),
            React.createElement('p', { className: 'status' },
              count > 0 ? React.createElement('span', { className: 'positive' }, '↑ Positive') :
              count < 0 ? React.createElement('span', { className: 'negative' }, '↓ Negative') :
              React.createElement('span', { className: 'zero' }, '● Zero')
            )
          )
        );
      };
    })(#{r})`
  end
end
