# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DebugHelpers Demo', type: :feature do
  describe 'Basic Logging' do
    it 'logs debug messages' do
      within('[data-controller="debug-demo"]') do
        click_button 'debug_log'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged debug messages')
      end
    end

    it 'logs warning messages' do
      within('[data-controller="debug-demo"]') do
        click_button 'debug_warn'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged warning messages')
      end
    end

    it 'logs error messages' do
      within('[data-controller="debug-demo"]') do
        click_button 'debug_error'
        expect(find('[data-debug-demo-target="status"]').text).to include('Logged error messages')
      end
    end

    it 'inspects objects' do
      within('[data-controller="debug-demo"]') do
        click_button 'debug_inspect'
        expect(find('[data-debug-demo-target="status"]').text).to include('Inspected objects')
      end
    end
  end

  describe 'Grouped Output' do
    it 'creates open groups' do
      within('[data-controller="group-demo"]') do
        click_button 'debug_group'
        expect(find('[data-group-demo-target="status"]').text).to include('Created open group')
      end
    end

    it 'creates collapsed groups' do
      within('[data-controller="group-demo"]') do
        click_button 'debug_group_collapsed'
        expect(find('[data-group-demo-target="status"]').text).to include('Created collapsed group')
      end
    end
  end

  describe 'Performance Measurement' do
    it 'measures execution time' do
      within('[data-controller="perf-demo"]') do
        click_button 'debug_measure'
        expect(find('[data-perf-demo-target="status"]').text).to include('Calculation result')
      end
    end

    it 'uses timer for async operations' do
      within('[data-controller="perf-demo"]') do
        click_button 'debug_time/time_end'
        expect(find('[data-perf-demo-target="status"]').text).to include('Timer started')

        # Wait for async completion
        sleep 0.6
        expect(find('[data-perf-demo-target="status"]').text).to include('Timer completed')
      end
    end
  end

  describe 'Debug Mode Toggle' do
    it 'checks debug status' do
      within('[data-controller="toggle-demo"]') do
        click_button 'Check Status'
        expect(find('[data-toggle-demo-target="status"]').text).to include('Debug mode:')
      end
    end

    it 'enables and disables debug mode' do
      within('[data-controller="toggle-demo"]') do
        click_button 'debug_disable!'
        expect(find('[data-toggle-demo-target="status"]').text).to include('disabled')

        click_button 'debug_enable!'
        expect(find('[data-toggle-demo-target="status"]').text).to include('enabled')
      end
    end
  end

  describe 'Assertions & Tracing' do
    it 'passes assertions' do
      within('[data-controller="assert-demo"]') do
        click_button 'Assert (pass)'
        expect(find('[data-assert-demo-target="status"]').text).to include('Assertions passed')
      end
    end

    it 'shows trace output' do
      within('[data-controller="assert-demo"]') do
        click_button 'debug_trace'
        expect(find('[data-assert-demo-target="status"]').text).to include('Stack trace logged')
      end
    end
  end

  describe 'Call Counting' do
    it 'increments and resets counter' do
      within('[data-controller="count-demo"]') do
        3.times { click_button 'debug_count' }
        expect(find('[data-count-demo-target="status"]').text).to include('Click counter: 3')

        click_button 'debug_count_reset'
        expect(find('[data-count-demo-target="status"]').text).to include('0')
      end
    end
  end

  describe 'Table Output' do
    it 'shows array as table' do
      within('[data-controller="table-demo"]') do
        click_button 'Array Table'
        expect(find('[data-table-demo-target="status"]').text).to include('Array table displayed')
      end
    end

    it 'shows hash as table' do
      within('[data-controller="table-demo"]') do
        click_button 'Hash Table'
        expect(find('[data-table-demo-target="status"]').text).to include('Hash table displayed')
      end
    end
  end

  describe 'Stimulus Integration' do
    it 'logs connect events' do
      within('[data-controller="stimulus-demo"]') do
        click_button 'Log Connect'
        expect(find('[data-stimulus-demo-target="status"]').text).to include('Logged connect event')
      end
    end

    it 'logs action events' do
      within('[data-controller="stimulus-demo"]') do
        click_button 'Log Action'
        expect(find('[data-stimulus-demo-target="status"]').text).to include('Logged action event')
      end
    end
  end
end
