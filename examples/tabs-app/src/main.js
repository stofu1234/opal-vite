// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Stimulus
import { Application, Controller } from "@hotwired/stimulus"

// Expose Controller and application globally FIRST (before any Opal code loads)
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('Stimulus globals set up, loading Opal controllers...')

// Use dynamic import to ensure Controller is available before Opal code executes
import('../app/opal/application.rb').then(() => {
  console.log('✅ Tabs app started with Opal controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
