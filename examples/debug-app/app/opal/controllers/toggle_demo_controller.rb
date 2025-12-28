# backtick_javascript: true

class ToggleDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
    check_status
  end

  def enable_debug
    debug_enable!
    update_status('Debug mode: enabled')
    debug_log('Debug mode was just enabled')
  end

  def disable_debug
    debug_disable!
    update_status('Debug mode: disabled')
    # This won't show because debug is now disabled
    debug_log('This message will not appear')
  end

  def check_status
    enabled = debug_enabled?
    update_status("Debug mode: #{enabled ? 'enabled' : 'disabled'}")
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
