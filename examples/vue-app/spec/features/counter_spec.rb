# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Counter App', type: :feature do
  let(:counter_selector) { '#counter-app' }
  let(:count_selector) { '#counter-app .count-value' }

  describe 'initial state' do
    it 'displays initial count of 0' do
      expect(find(count_selector)).to have_text('0')
    end

    it 'shows zero status' do
      within(counter_selector) do
        expect(page).to have_css('.zero')
      end
    end
  end

  describe 'increment' do
    it 'increments count when + button is clicked' do
      find("#{counter_selector} .btn-increment").click

      expect(find(count_selector)).to have_text('1')
    end

    it 'shows positive status after increment' do
      find("#{counter_selector} .btn-increment").click

      within(counter_selector) do
        expect(page).to have_css('.positive')
      end
    end
  end

  describe 'decrement' do
    it 'decrements count when - button is clicked' do
      find("#{counter_selector} .btn-decrement").click

      expect(find(count_selector)).to have_text('-1')
    end

    it 'shows negative status after decrement' do
      find("#{counter_selector} .btn-decrement").click

      within(counter_selector) do
        expect(page).to have_css('.negative')
      end
    end
  end

  describe 'reset' do
    it 'resets count to 0 when Reset button is clicked' do
      # Increment a few times
      3.times { find("#{counter_selector} .btn-increment").click }
      expect(find(count_selector)).to have_text('3')

      # Reset
      find("#{counter_selector} .btn-reset").click

      expect(find(count_selector)).to have_text('0')
    end
  end

  describe 'computed properties' do
    it 'displays correct doubled value' do
      2.times { find("#{counter_selector} .btn-increment").click }

      within(counter_selector) do
        expect(page).to have_text('Double: 4')
      end
    end

    it 'displays correct absolute value for negative numbers' do
      3.times { find("#{counter_selector} .btn-decrement").click }

      within(counter_selector) do
        expect(page).to have_text('Absolute: 3')
      end
    end
  end
end
