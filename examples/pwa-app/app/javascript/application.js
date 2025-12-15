import { Application, Controller } from '@hotwired/stimulus';

// Create Stimulus application
const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

// Make Controller and StimulusApplication globally available for Opal
window.Controller = Controller;
window.StimulusApplication = application;

// Load Opal application
import('/app/opal/application.rb');
