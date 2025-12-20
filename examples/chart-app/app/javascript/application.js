// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

// Import Stimulus
import { Application, Controller } from "@hotwired/stimulus"

// Import Chart.js
import Chart from 'chart.js/auto'

// Make Chart.js available globally for Opal
window.Chart = Chart

// Expose for Opal
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus

console.log('Chart App: Stimulus and Chart.js initialized')

// Dynamic import to ensure globals are available
import('../opal/application.rb').then(() => {
  console.log('✅ Chart App started with Ruby controllers!')
}).catch(error => {
  console.error('Failed to load Opal controllers:', error)
})
