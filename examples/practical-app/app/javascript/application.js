// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Hotwire stack
import { Application, Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

// Expose for Opal
window.Controller = Controller
window.Turbo = Turbo
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('Practical App: Stimulus & Turbo initialized')

// Dynamic import to ensure globals are available
import('../opal/application.rb').then(() => {
  console.log('✅ Practical App started with Ruby controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
