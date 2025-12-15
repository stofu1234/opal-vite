import React, { useState } from 'react'

export function Greeting() {
  const [name, setName] = useState('')

  return (
    <div className="greeting-container">
      <div className="greeting-card">
        <h2>Greeting Component</h2>

        <div className="input-group">
          <label>Enter your name:</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Your name here..."
            className="name-input"
          />
        </div>

        {name ? (
          <div className="greeting-message">
            <h3>Hello, {name}! 👋</h3>
            <p>Welcome to Opal + React + Vite!</p>
          </div>
        ) : (
          <div className="greeting-placeholder">
            <p>Type your name to see a greeting</p>
          </div>
        )}
      </div>
    </div>
  )
}
