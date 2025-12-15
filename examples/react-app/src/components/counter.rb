require 'native'

class Counter
  def self.create
    react = Native(`window.React`)

    react.createElement('div', { className: 'counter-container' },
      react.createElement('div', { className: 'counter-card' },
        react.createElement('h2', nil, 'Counter Component (Ruby + React)'),
        react.createElement(CounterComponent, nil)
      )
    )
  end
end

class CounterComponent
  def self.to_n
    react = Native(`window.React`)

    `function() {
      const [count, setCount] = #{react}.useState(0);

      const increment = () => setCount(count + 1);
      const decrement = () => setCount(count - 1);
      const reset = () => setCount(0);

      return #{react}.createElement('div', null,
        #{react}.createElement('div', { className: 'counter-display' },
          #{react}.createElement('div', { className: 'count-value' }, count)
        ),
        #{react}.createElement('div', { className: 'counter-controls' },
          #{react}.createElement('button',
            { className: 'btn btn-decrement', onClick: decrement },
            '−'
          ),
          #{react}.createElement('button',
            { className: 'btn btn-reset', onClick: reset },
            'Reset'
          ),
          #{react}.createElement('button',
            { className: 'btn btn-increment', onClick: increment },
            '+'
          )
        ),
        #{react}.createElement('div', { className: 'counter-info' },
          #{react}.createElement('p', null, 'Current count: ' + count),
          #{react}.createElement('p', { className: 'status' },
            count > 0 ? #{react}.createElement('span', { className: 'positive' }, '↑ Positive') :
            count < 0 ? #{react}.createElement('span', { className: 'negative' }, '↓ Negative') :
            #{react}.createElement('span', { className: 'zero' }, '● Zero')
          )
        )
      );
    }`
  end
end
