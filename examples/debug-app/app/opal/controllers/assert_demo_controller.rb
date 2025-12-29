# backtick_javascript: true

class AssertDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
  end

  def pass_assertion
    value = 42
    debug_assert(value == 42, "Value should be 42")
    debug_assert(value > 0, "Value should be positive")
    update_status('Assertions passed (no console errors)')
  end

  def fail_assertion
    value = 10
    debug_assert(value == 42, "Expected 42 but got #{value}")
    update_status('Assertion failed - check console for error')
  end

  def show_trace
    outer_method
    update_status('Stack trace logged - check console')
  end

  private

  def outer_method
    inner_method
  end

  def inner_method
    debug_trace('Current call stack')
  end

  def update_status(message)
    status_target.inner_text = message
  end
end
