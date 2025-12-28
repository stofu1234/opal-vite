# backtick_javascript: true

class TableDemoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  self.targets = ['status']

  def connect
    debug_stimulus_connect
  end

  def show_array_table
    users = [
      { name: 'Alice', age: 30, role: 'Developer' },
      { name: 'Bob', age: 25, role: 'Designer' },
      { name: 'Carol', age: 35, role: 'Manager' }
    ]

    debug_table(users)
    update_status('Array table displayed - check console')
  end

  def show_hash_table
    config = {
      environment: 'development',
      debug: true,
      version: '0.3.2',
      features: ['debug_helpers', 'error_messages']
    }

    debug_table(config)
    update_status('Hash table displayed - check console')
  end

  private

  def update_status(message)
    status_target.inner_text = message
  end
end
