# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DebugHelpers Demo', type: :feature do
  describe 'All buttons work without JS errors' do
    it 'clicks all buttons in debug-demo section without errors' do
      within('[data-controller="debug-demo"]') do
        click_button_without_errors 'debug_log'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged debug messages')

        click_button_without_errors 'debug_warn'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged warning messages')

        click_button_without_errors 'debug_error'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged error messages')

        click_button_without_errors 'debug_inspect'
        expect(find('[data-debug-demo-target="status"]').text).to include('Inspected objects')
      end
    end

    it 'clicks all buttons in group-demo section without errors' do
      within('[data-controller="group-demo"]') do
        click_button_without_errors 'debug_group'
        expect(find('[data-group-demo-target="status"]').text).to include('Created open group')

        click_button_without_errors 'debug_group_collapsed'
        expect(find('[data-group-demo-target="status"]').text).to include('Created collapsed group')
      end
    end

    it 'clicks all buttons in perf-demo section without errors' do
      within('[data-controller="perf-demo"]') do
        click_button_without_errors 'debug_measure'
        expect(find('[data-perf-demo-target="status"]').text).to include('Calculation result')

        click_button_without_errors 'debug_time/time_end'
        expect(find('[data-perf-demo-target="status"]').text).to include('Timer started')

        # Wait for async completion
        sleep 0.6
        expect(find('[data-perf-demo-target="status"]').text).to include('Timer completed')
        expect_no_js_errors
      end
    end

    it 'clicks all buttons in toggle-demo section without errors' do
      within('[data-controller="toggle-demo"]') do
        click_button_without_errors 'Check Status'
        expect(find('[data-toggle-demo-target="status"]').text).to include('Debug mode:')

        click_button_without_errors 'debug_disable!'
        expect(find('[data-toggle-demo-target="status"]').text).to include('disabled')

        click_button_without_errors 'debug_enable!'
        expect(find('[data-toggle-demo-target="status"]').text).to include('enabled')
      end
    end

    it 'clicks all buttons in assert-demo section without errors' do
      within('[data-controller="assert-demo"]') do
        click_button_without_errors 'Assert (pass)'
        expect(find('[data-assert-demo-target="status"]').text).to include('Assertions passed')

        # Note: Assert (fail) intentionally logs to console.error but doesn't throw
        click_button_without_errors 'Assert (fail)'
        expect(find('[data-assert-demo-target="status"]').text).to include('Assertion failed')

        click_button_without_errors 'debug_trace'
        expect(find('[data-assert-demo-target="status"]').text).to include('Stack trace logged')
      end
    end

    it 'clicks all buttons in count-demo section without errors' do
      within('[data-controller="count-demo"]') do
        3.times do
          click_button_without_errors 'debug_count'
        end
        expect(find('[data-count-demo-target="status"]').text).to include('Click counter: 3')

        click_button_without_errors 'debug_count_reset'
        expect(find('[data-count-demo-target="status"]').text).to include('0')
      end
    end

    it 'clicks all buttons in table-demo section without errors' do
      within('[data-controller="table-demo"]') do
        click_button_without_errors 'Array Table'
        expect(find('[data-table-demo-target="status"]').text).to include('Array table displayed')

        click_button_without_errors 'Hash Table'
        expect(find('[data-table-demo-target="status"]').text).to include('Hash table displayed')
      end
    end

    it 'clicks all buttons in stimulus-demo section without errors' do
      within('[data-controller="stimulus-demo"]') do
        click_button_without_errors 'Log Connect'
        expect(find('[data-stimulus-demo-target="status"]').text).to include('Logged connect event')

        click_button_without_errors 'Log Action'
        expect(find('[data-stimulus-demo-target="status"]').text).to include('Logged action event')
      end
    end
  end

  describe 'Complete button coverage test' do
    it 'clicks every button on the page without JS errors' do
      # Find all buttons on the page
      buttons = all('button')
      expect(buttons.count).to be > 0

      buttons.each do |button|
        button_text = button.text
        next if button_text.empty?

        # Click the button
        button.click
        sleep 0.1 # Allow any async errors to surface

        # Verify page is still responsive (would fail if JS error occurred)
        expect_no_js_errors
      end
    end
  end
end
