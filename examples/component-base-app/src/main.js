// Import the Opal runtime first (required for production builds)
import '/@opal-runtime'

// Load the Ruby application (compiled by vite-plugin-opal)
import './main.rb'

console.log('OpalComponent example loaded')
