// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Load React app
import React from 'react'
import ReactDOM from 'react-dom/client'
import { App } from './app.jsx'
import './styles.css'

// Load Ruby code (for orchestration and additional logic)
import './main.rb'

// FunctionalComponent (src/components/counter.rb) calls React through
// window.React, so expose it before building the Ruby component.
window.React = React
const RubyCounter = window.createRubyCounter()

// Mount React app
const root = ReactDOM.createRoot(document.getElementById('root'))
root.render(<App rubyCounter={RubyCounter} />)

console.log('✅ React app mounted!')
