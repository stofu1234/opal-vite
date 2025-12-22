// Setup snabbdom globally FIRST (required by snabberb gem)
import './snabbdom-setup.js'

// Import Opal runtime (required for production builds)
import '/@opal-runtime'

// Snabberb + Opal + Vite Example
console.log('Snabberb + Opal + Vite Example')
console.log('Ruby version:', Opal.RUBY_VERSION)

// Import Opal application
import '../app/opal/application.rb'

console.log('Application loaded!')
