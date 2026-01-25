# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'FunctionalComponent', type: :feature do
  describe 'Counter component using FunctionalComponent' do
    let(:count_value) { '.count-value' }
    let(:increment_btn) { '.btn-increment' }
    let(:decrement_btn) { '.btn-decrement' }
    let(:reset_btn) { '.btn-reset' }

    it 'renders with initial state from use_state' do
      expect(page).to have_css(count_value, text: '0')
      expect(page).to have_css('.zero', text: 'Zero')
    end

    it 'increments using set_count.with functional update' do
      find(increment_btn).click
      expect(page).to have_css(count_value, text: '1')
      expect(page).to have_css('.positive', text: 'Positive')

      find(increment_btn).click
      expect(page).to have_css(count_value, text: '2')
    end

    it 'decrements using set_count.with functional update' do
      find(decrement_btn).click
      expect(page).to have_css(count_value, text: '-1')
      expect(page).to have_css('.negative', text: 'Negative')

      find(decrement_btn).click
      expect(page).to have_css(count_value, text: '-2')
    end

    it 'resets using set_count.to with specific value' do
      # Increment several times
      5.times { find(increment_btn).click }
      expect(page).to have_css(count_value, text: '5')

      # Reset to 0 using set_count.to(0)
      find(reset_btn).click
      expect(page).to have_css(count_value, text: '0')
      expect(page).to have_css('.zero', text: 'Zero')
    end

    it 'handles multiple rapid state updates correctly' do
      # Rapid increment
      10.times { find(increment_btn).click }
      expect(page).to have_css(count_value, text: '10')

      # Rapid decrement
      5.times { find(decrement_btn).click }
      expect(page).to have_css(count_value, text: '5')

      # Reset
      find(reset_btn).click
      expect(page).to have_css(count_value, text: '0')
    end

    it 'transitions between positive, negative, and zero states' do
      # Start at zero
      expect(page).to have_css('.zero')

      # Go positive
      find(increment_btn).click
      expect(page).to have_css('.positive')
      expect(page).to have_no_css('.zero')
      expect(page).to have_no_css('.negative')

      # Go back to zero
      find(decrement_btn).click
      expect(page).to have_css('.zero')
      expect(page).to have_no_css('.positive')

      # Go negative
      find(decrement_btn).click
      expect(page).to have_css('.negative')
      expect(page).to have_no_css('.zero')
    end

    it 'displays current count info text' do
      find(increment_btn).click
      find(increment_btn).click
      find(increment_btn).click

      expect(page).to have_css('.counter-info p', text: 'Current count: 3')
    end
  end
end
