// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Stimulus and ActionCable
import { Application, Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Expose Controller for Opal
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

// Make ActionCable available globally for OpalVite helpers
window.ActionCable = { createConsumer }

console.log('ActionCable App: Stimulus initialized')

// Dynamic import to ensure globals are available
import('../app/opal/application.rb').then(() => {
  console.log('ActionCable App: Ruby controllers loaded!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
