import React from 'react'
import { Counter } from './Counter'
import { Greeting } from './Greeting'
import { TodoList } from './TodoList'

export function App() {
  return (
    <div className="app">
      <div className="components-grid">
        <Counter />
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
