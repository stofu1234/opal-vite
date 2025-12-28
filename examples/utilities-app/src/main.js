import { Application } from '@hotwired/stimulus'

// Initialize Stimulus
window.Stimulus = Application.start()

// Import Opal application (this loads controllers)
import '../app/opal/application.rb'
