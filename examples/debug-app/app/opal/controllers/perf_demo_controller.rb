# backtick_javascript: true

class PerfDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
  end

  def measure_time
    result = debug_measure('Heavy Calculation') do
      # Simulate some work
      sum = 0
      10000.times { |i| sum += i }
      sum
    end

    update_status("Calculation result: #{result} - check console for timing")
  end

  def timer_demo
    debug_time('API Request')

    # Simulate async operation
    `setTimeout(() => #{complete_timer}, 500)`

    update_status('Timer started... waiting 500ms')
  end

  private

  def complete_timer
    debug_time_end('API Request')
    update_status('Timer completed - check console for elapsed time')
  end

  def update_status(message)
    status_target.inner_text = message
  end
end
