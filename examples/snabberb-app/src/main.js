// Import snabbdom and expose globally (required by snabberb gem)
// This MUST be done before Opal runtime loads
import * as snabbdom from 'snabbdom'
window.snabbdom = snabbdom

// Import Opal runtime (required for production builds)
import '/@opal-runtime'

// Snabberb + Opal + Vite Example
console.log('Snabberb + Opal + Vite Example')
console.log('Ruby version:', Opal.RUBY_VERSION)

// Import Opal application
import '../app/opal/application.rb'

console.log('Application loaded!')
