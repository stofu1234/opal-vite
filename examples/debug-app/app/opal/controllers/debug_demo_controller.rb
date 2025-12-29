# backtick_javascript: true

class DebugDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
  end

  def log_message
    debug_log('This is a debug message')
    debug_log('Message with data', { key: 'value', count: 42 })
    update_status('Logged debug messages - check console')
  end

  def warn_message
    debug_warn('This is a warning message')
    debug_warn('Warning with context', { level: 'medium', action: 'check config' })
    update_status('Logged warning messages - check console')
  end

  def error_message
    debug_error('This is an error message')
    debug_error('Error with details', { code: 500, reason: 'Something went wrong' })
    update_status('Logged error messages - check console')
  end

  def inspect_object
    sample_hash = { name: 'Ruby', version: '3.2', framework: 'Opal' }
    sample_array = [1, 2, 3, 'four', :five]

    debug_inspect(sample_hash, 'Configuration')
    debug_inspect(sample_array, 'Items')
    update_status('Inspected objects - check console')
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
