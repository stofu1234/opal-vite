# backtick_javascript: true

class GroupDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
  end

  def open_group
    debug_group('User Action Flow') do
      debug_log('Step 1: User clicked button')
      debug_log('Step 2: Processing request')
      debug_log('Step 3: Updating UI')
    end
    update_status('Created open group - check console')
  end

  def collapsed_group
    debug_group_collapsed('Request Details') do
      debug_log('URL: /api/users')
      debug_log('Method: GET')
      debug_log('Headers: { "Content-Type": "application/json" }')
      debug_log('Response: 200 OK')
    end
    update_status('Created collapsed group - click to expand in console')
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
