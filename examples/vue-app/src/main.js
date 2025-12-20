// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Vue.js 3 + Opal Loader
// This file serves as the entry point that loads the Ruby code

console.log('Loading Opal + Vue.js application...')

// Import the Ruby application using static import
// This ensures Vite transforms the .rb file through the Opal plugin
import './main.rb'

console.log('Opal + Vue.js application loaded!')
