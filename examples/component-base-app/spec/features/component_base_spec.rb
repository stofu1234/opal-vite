# frozen_string_literal: true

require_relative '../spec_helper'

# E2E test for the framework-agnostic OpalComponent base class (issue #55).
# Because the driver runs with js_errors: true, any runtime error thrown by
# the base class (render / set_state / event binding) fails these tests — so
# this also verifies the component's runtime behavior, not just compilation.
RSpec.describe 'OpalComponent base class (component-base-app)', type: :feature do
  # Click a control button and wait for the count display to reach +expected+.
  def click_and_expect(act, expected)
    find("button[data-act='#{act}']", wait: 5).click
    expect(page).to have_css('.count', text: expected.to_s, wait: 10)
  end

  describe 'Initial render' do
    it 'renders the component heading' do
      expect(page).to have_css('h2', text: 'OpalComponent Counter')
    end

    it 'starts the counter at 0' do
      expect(page).to have_css('.count', text: '0')
    end

    it 'renders the three control buttons' do
      expect(page).to have_css("button[data-act='inc']")
      expect(page).to have_css("button[data-act='dec']")
      expect(page).to have_css("button[data-act='reset']")
    end
  end

  describe 'set_state re-rendering' do
    it 'increments the count' do
      click_and_expect('inc', 1)
    end

    it 'increments multiple times' do
      click_and_expect('inc', 1)
      click_and_expect('inc', 2)
      click_and_expect('inc', 3)
    end

    it 'decrements below zero' do
      click_and_expect('dec', -1)
      click_and_expect('dec', -2)
    end

    it 'resets to zero from a positive value' do
      click_and_expect('inc', 1)
      click_and_expect('inc', 2)
      click_and_expect('reset', 0)
    end

    it 'handles a combined increment / decrement / reset sequence' do
      click_and_expect('inc', 1)
      click_and_expect('inc', 2)
      click_and_expect('dec', 1)
      click_and_expect('reset', 0)
    end

    it 'rebinds event listeners after each re-render' do
      # Each set_state replaces innerHTML and re-runs after_render; clicking
      # several times in a row proves the freshly rendered buttons stay wired.
      (1..5).each { |i| click_and_expect('inc', i) }
    end
  end
end
