import React, { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div className="counter-container">
      <div className="counter-card">
        <h2>Counter Component</h2>

        <div className="counter-display">
          <div className="count-value">{count}</div>
        </div>

        <div className="counter-controls">
          <button
            className="btn btn-decrement"
            onClick={() => setCount(count - 1)}
          >
            −
          </button>
          <button className="btn btn-reset" onClick={() => setCount(0)}>
            Reset
          </button>
          <button
            className="btn btn-increment"
            onClick={() => setCount(count + 1)}
          >
            +
          </button>
        </div>

        <div className="counter-info">
          <p>Current count: {count}</p>
          <p className="status">
            {count > 0 ? (
              <span className="positive">↑ Positive</span>
            ) : count < 0 ? (
              <span className="negative">↓ Negative</span>
            ) : (
              <span className="zero">● Zero</span>
            )}
          </p>
        </div>
      </div>
    </div>
  )
}
