# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Tabs Navigation', type: :feature do
  describe 'Initial State' do
    it 'shows the page title' do
      expect(page).to have_content('Tab Navigation Demo')
    end

    it 'displays all four tab buttons' do
      expect(page).to have_css('.tab-button', count: 4)
      expect(page).to have_button('Overview')
      expect(page).to have_button('Features')
      expect(page).to have_button('Documentation')
      expect(page).to have_button('Settings')
    end

    it 'has the first tab active by default' do
      first_tab = find('.tab-button', text: 'Overview')
      expect(first_tab[:class]).to include('tab-active')
    end

    it 'shows the first panel by default' do
      expect(page).to have_css('.panel.panel-visible', count: 1)
      expect(page).to have_content('Welcome to Tabs Demo')
      expect(page).to have_content('Current Panel Index: 0')
    end

    it 'hides the other panels initially' do
      # Hidden elements have display: none, use visible: :all to find them
      expect(page).to have_css('.panel.panel-hidden', visible: :all, count: 3)
    end
  end

  describe 'Tab Selection' do
    it 'switches to Features tab when clicked' do
      click_button 'Features'

      # Wait for panel transition
      wait_for_dom_stable

      expect(page).to have_css('.tab-button.tab-active', text: 'Features')
      expect(page).to have_content('Key Features')
      expect(page).to have_content('Current Panel Index: 1')
    end

    it 'switches to Documentation tab when clicked' do
      click_button 'Documentation'

      wait_for_dom_stable

      expect(page).to have_css('.tab-button.tab-active', text: 'Documentation')
      expect(page).to have_content('How It Works')
      expect(page).to have_content('Current Panel Index: 2')
    end

    it 'switches to Settings tab when clicked' do
      click_button 'Settings'

      wait_for_dom_stable

      expect(page).to have_css('.tab-button.tab-active', text: 'Settings')
      expect(page).to have_content('Settings & Configuration')
      expect(page).to have_content('Current Panel Index: 3')
    end

    it 'switches back to Overview tab from another tab' do
      click_button 'Features'
      wait_for_dom_stable
      expect(page).to have_content('Key Features')

      click_button 'Overview'
      wait_for_dom_stable

      expect(page).to have_css('.tab-button.tab-active', text: 'Overview')
      expect(page).to have_content('Welcome to Tabs Demo')
      expect(page).to have_content('Current Panel Index: 0')
    end
  end

  describe 'Tab Button Styling' do
    it 'removes active class from previous tab when switching' do
      # Initially Overview is active
      expect(page).to have_css('.tab-button.tab-active', text: 'Overview')

      click_button 'Features'
      wait_for_dom_stable

      # Overview should no longer be active
      overview_tab = find('.tab-button', text: 'Overview')
      expect(overview_tab[:class]).not_to include('tab-active')

      # Features should now be active
      expect(page).to have_css('.tab-button.tab-active', text: 'Features')
    end

    it 'only has one active tab at a time' do
      click_button 'Settings'
      wait_for_dom_stable

      # Should only have one active tab
      expect(page).to have_css('.tab-button.tab-active', count: 1)
    end
  end

  describe 'Panel Visibility' do
    it 'only shows one panel at a time' do
      click_button 'Documentation'
      wait_for_dom_stable

      expect(page).to have_css('.panel.panel-visible', count: 1)
      # Hidden elements have display: none, use visible: :all to find them
      expect(page).to have_css('.panel.panel-hidden', visible: :all, count: 3)
    end

    it 'hides the previous panel when switching' do
      # Click through all tabs to verify panels hide properly
      %w[Features Documentation Settings Overview].each do |tab_name|
        click_button tab_name
        wait_for_dom_stable

        expect(page).to have_css('.panel.panel-visible', count: 1)
        expect(page).to have_css('.panel.panel-hidden', visible: :all, count: 3)
      end
    end
  end

  describe 'Panel Content' do
    it 'displays correct content for Features panel' do
      click_button 'Features'
      wait_for_dom_stable

      expect(page).to have_content('Outlets API')
      expect(page).to have_content('Helper Methods')
      expect(page).to have_content('Event Dispatch')
    end

    it 'displays code examples in Documentation panel' do
      click_button 'Documentation'
      wait_for_dom_stable

      expect(page).to have_content('TabsController (Ruby)')
      expect(page).to have_content('PanelController (Ruby)')
      expect(page).to have_css('pre code')
    end

    it 'displays checkboxes in Settings panel' do
      click_button 'Settings'
      wait_for_dom_stable

      expect(page).to have_css('input[type="checkbox"]', count: 3)
      expect(page).to have_content('Enable animations')
      expect(page).to have_content('Use Outlets API')
      expect(page).to have_content('Dispatch custom events')
    end
  end

  describe 'Rapid Tab Switching' do
    it 'handles rapid clicks without errors' do
      5.times do
        click_button 'Features'
        click_button 'Documentation'
        click_button 'Settings'
        click_button 'Overview'
      end

      wait_for_dom_stable

      # Should still be in a valid state
      expect(page).to have_css('.tab-button.tab-active', count: 1)
      expect(page).to have_css('.panel.panel-visible', count: 1)
    end
  end

  describe 'Outlets API Integration' do
    it 'tabs controller can connect to panel outlets' do
      # Verify the outlet connection is working by checking that panels respond
      # when tabs controller calls call_all_outlets
      click_button 'Features'
      wait_for_dom_stable

      # The Features panel should be visible
      features_panel = find('.panel', text: 'Key Features')
      expect(features_panel[:class]).to include('panel-visible')

      # The Overview panel should be hidden (use visible: :all to find hidden elements)
      overview_panel = find('.panel', text: 'Welcome to Tabs Demo', visible: :all)
      expect(overview_panel[:class]).to include('panel-hidden')
    end
  end

  describe 'Custom Events (stimulus_dispatch)' do
    it 'panels respond to tabs:change events' do
      # This tests the event-based communication between tabs and panel controllers
      click_button 'Settings'
      wait_for_dom_stable

      # The correct panel index should be shown
      expect(page).to have_content('Current Panel Index: 3')

      # Other panels should have their correct indices
      click_button 'Overview'
      wait_for_dom_stable
      expect(page).to have_content('Current Panel Index: 0')
    end
  end
end
