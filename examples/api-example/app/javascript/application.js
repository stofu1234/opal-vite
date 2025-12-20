// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Stimulus
import { Application, Controller } from "@hotwired/stimulus"

// Expose for Opal
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('API Example: Stimulus initialized')

// Dynamic import to ensure globals are available
import('../opal/application.rb').then(() => {
  console.log('✅ API Example started with Ruby controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
