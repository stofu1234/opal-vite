// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Hotwire Stimulus
import { Application, Controller } from "@hotwired/stimulus"

// Expose for Opal
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('CRUD App: Stimulus initialized')

// Dynamic import to ensure globals are available
import('../app/opal/application.rb').then(() => {
  console.log('✅ CRUD App started with Ruby controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
