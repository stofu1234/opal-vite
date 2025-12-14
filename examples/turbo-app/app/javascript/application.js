// Import Hotwire stack
import { Application, Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

// Expose for Opal
window.Controller = Controller
window.Turbo = Turbo
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('Turbo + Stimulus globals set up, loading Opal controllers...')

// Log Turbo events for debugging
document.addEventListener('turbo:load', () => {
  console.log('✅ Turbo:load event fired')
})

document.addEventListener('turbo:before-visit', (event) => {
  console.log('→ Turbo:before-visit', event.detail.url)
})

document.addEventListener('turbo:visit', (event) => {
  console.log('→ Turbo:visit', event.detail.action)
})

// Dynamic import to ensure globals are available
import('../opal/application.rb').then(() => {
  console.log('✅ Turbo + Stimulus application started with Opal controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
