# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Counter App', type: :feature do
  # Helper to wait for Stimulus controller to be fully ready
  def wait_for_controller_ready(timeout: 10)
    start = Time.now
    loop do
      ready = page.evaluate_script(<<~JS)
        (function() {
          var el = document.querySelector('[data-controller="counter"]');
          if (!el) return false;
          if (!window.Stimulus) return false;
          var ctrl = window.Stimulus.getControllerForElementAndIdentifier(el, 'counter');
          return ctrl && typeof ctrl.increment === 'function';
        })()
      JS
      return if ready

      break if Time.now - start > timeout
      sleep 0.1
    end
  end

  # Helper to click increment and wait for the value to update
  def click_increment_and_wait(expected_value)
    # Ensure controller is ready
    wait_for_controller_ready

    # Wait for button and click using native click
    btn = find('button', text: '+ Increment', wait: 5)
    btn.click
    sleep 0.3

    # Wait for expected value
    expect(page).to have_css('[data-counter-target="display"]', text: expected_value.to_s, wait: 10)
  end

  # Helper to click decrement and wait for the value to update
  def click_decrement_and_wait(expected_value)
    # Ensure controller is ready
    wait_for_controller_ready

    # Wait for button and click using native click
    btn = find('button', text: '- Decrement', wait: 5)
    btn.click
    sleep 0.3

    # Wait for expected value
    expect(page).to have_css('[data-counter-target="display"]', text: expected_value.to_s, wait: 10)
  end

  # Helper to click reset and wait for value to be 0
  def click_reset_and_wait
    # Ensure controller is ready
    wait_for_controller_ready

    # Wait for button and click using native click
    btn = find('button', text: 'Reset', wait: 5)
    btn.click
    sleep 0.3

    # Wait for expected value
    expect(page).to have_css('[data-counter-target="display"]', text: '0', wait: 10)
  end

  describe 'Initial State' do
    it 'shows the page title' do
      expect(page).to have_content('Counter App')
    end

    it 'displays the subtitle' do
      expect(page).to have_content('Demonstrating Stimulus Values API with Opal')
    end

    it 'shows the counter display at 0' do
      expect(page).to have_css('[data-counter-target="display"]', text: '0')
    end

    it 'displays all control buttons' do
      expect(page).to have_button('- Decrement')
      expect(page).to have_button('Reset')
      expect(page).to have_button('+ Increment')
    end

    it 'shows the info panel with API documentation' do
      expect(page).to have_content('About this demo:')
      expect(page).to have_content('Values API')
    end
  end

  describe 'Increment Button' do
    it 'increments the counter by 1' do
      click_increment_and_wait(1)
    end

    it 'increments multiple times' do
      click_increment_and_wait(1)
      click_increment_and_wait(2)
      click_increment_and_wait(3)
    end
  end

  describe 'Decrement Button' do
    it 'decrements the counter by 1' do
      click_increment_and_wait(1)
      click_decrement_and_wait(0)
    end

    it 'can go negative' do
      click_decrement_and_wait(-1)
    end

    it 'decrements multiple times' do
      click_decrement_and_wait(-1)
      click_decrement_and_wait(-2)
      click_decrement_and_wait(-3)
    end
  end

  describe 'Reset Button' do
    it 'resets counter to 0 from positive value' do
      click_increment_and_wait(1)
      click_increment_and_wait(2)
      click_increment_and_wait(3)
      click_increment_and_wait(4)
      click_increment_and_wait(5)
      click_reset_and_wait
    end

    it 'resets counter to 0 from negative value' do
      click_decrement_and_wait(-1)
      click_decrement_and_wait(-2)
      click_decrement_and_wait(-3)
      click_reset_and_wait
    end
  end

  describe 'Combined Operations' do
    it 'handles increment, decrement, and reset sequence' do
      # Increment to 5
      click_increment_and_wait(1)
      click_increment_and_wait(2)
      click_increment_and_wait(3)
      click_increment_and_wait(4)
      click_increment_and_wait(5)

      # Decrement to 3
      click_decrement_and_wait(4)
      click_decrement_and_wait(3)

      # Increment to 4
      click_increment_and_wait(4)

      # Reset
      click_reset_and_wait
    end
  end

  describe 'Rapid Clicking' do
    it 'handles rapid increment clicks' do
      (1..10).each { |i| click_increment_and_wait(i) }
    end

    it 'handles rapid decrement clicks' do
      (-10..-1).to_a.reverse.each { |i| click_decrement_and_wait(i) }
    end

    it 'handles alternating rapid clicks' do
      5.times do |i|
        click_increment_and_wait(1)
        click_decrement_and_wait(0)
      end
    end
  end

  describe 'Values API Integration' do
    it 'uses data-counter-count-value attribute' do
      counter_element = find('[data-controller="counter"]')
      expect(counter_element['data-counter-count-value']).to eq('0')
    end

    it 'updates the data attribute when counter changes' do
      click_increment_and_wait(1)

      counter_element = find('[data-controller="counter"]')
      expect(counter_element['data-counter-count-value']).to eq('1')
    end
  end
end
