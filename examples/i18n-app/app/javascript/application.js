// Import Opal runtime first (required for production builds)
import '/@opal-runtime'

import { Application, Controller } from '@hotwired/stimulus';

// Create Stimulus application
const application = Application.start();

// Configure Stimulus development experience
application.debug = false;

// Expose for Opal (must match practical-app pattern)
window.Controller = Controller;
window.Stimulus = application;
window.application = application;

console.log('i18n App: Stimulus initialized');

// Dynamic import to ensure globals are available
import('/app/opal/application.rb').then(() => {
  console.log('✅ i18n App started with Ruby controllers!');
}).catch(error => {
  console.error('Failed to load Opal controllers:', error);
});
