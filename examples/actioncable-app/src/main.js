import { Application } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Make ActionCable available globally for OpalVite helpers
window.ActionCable = { createConsumer }

// Initialize Stimulus
const application = Application.start()
window.Stimulus = application

// Import and register Opal controllers
import("./application.rb").then((module) => {
  console.log("Opal controllers loaded")
})
