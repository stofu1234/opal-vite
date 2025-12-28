// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Hotwire stack
import { Application, Controller } from '@hotwired/stimulus'

// Expose Controller for Opal
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('Utilities App: Stimulus initialized')

// Dynamic import to ensure globals are available
import('../app/opal/application.rb').then(() => {
  console.log('Utilities App: Ruby controllers loaded!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
