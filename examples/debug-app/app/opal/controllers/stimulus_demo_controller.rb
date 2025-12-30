# backtick_javascript: true

class StimulusDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
    update_status('Controller connected - check console')
  end

  def disconnect
    debug_stimulus_disconnect
  end

  def log_connect
    debug_stimulus_connect
    update_status('Logged connect event - check console')
  end

  def log_action
    # Simulate an event object
    event_info = { type: 'click', target: 'button' }
    debug_stimulus_action('log_action', event_info)
    update_status('Logged action event - check console')
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
