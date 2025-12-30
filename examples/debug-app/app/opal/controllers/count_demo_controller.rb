# backtick_javascript: true

class CountDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def initialize(*)
    super
    @local_count = 0
  end

  def connect
    debug_stimulus_connect
    @local_count = 0
  end

  def increment_count
    @local_count += 1
    debug_count('button_clicks')
    update_status("Click counter: #{@local_count}")
  end

  def reset_count
    @local_count = 0
    debug_count_reset('button_clicks')
    update_status('Click counter: 0 (reset)')
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
