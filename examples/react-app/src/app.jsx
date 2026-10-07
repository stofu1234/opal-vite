import React from 'react'
import { Counter } from './Counter'
import { Greeting } from './Greeting'
import { TodoList } from './TodoList'

export function App({ rubyCounter: RubyCounter }) {
  return (
    <div className="app">
      <div className="components-grid">
        <Counter />
        {RubyCounter && (
          <div className="counter-container" id="ruby-counter">
            <div className="counter-card">
              <h2>Counter Component (Ruby FunctionalComponent)</h2>
              <RubyCounter />
            </div>
          </div>
        )}
        <Greeting />
        <TodoList />
      </div>

      <footer className="app-footer">
        <p>
          Built with <strong>Ruby (Opal)</strong> +{' '}
          <strong>React</strong> + <strong>Vite</strong>
        </p>
        <p className="footer-note">
          React components in JSX, orchestrated by Ruby! 🚀
        </p>
      </footer>
    </div>
  )
}
