# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Stimulus Components + Opal + Vite', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'Stimulus Components')
    end

    it 'displays the subtitle' do
      expect(page).to have_css('.subtitle', text: 'Reusable UI components')
    end

    it 'displays the footer with links' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Vite')
    end

    it 'displays all five component sections' do
      expect(page).to have_css('[data-controller="accordion"]')
      expect(page).to have_css('[data-controller="dropdown"]')
      expect(page).to have_css('[data-controller="toggle"]', minimum: 1)
      expect(page).to have_css('[data-controller="tooltip"]', minimum: 1)
      expect(page).to have_css('[data-controller="tabs"]')
    end
  end

  describe 'Accordion Controller' do
    let(:first_header) { '.accordion:nth-child(1) .accordion-header' }
    let(:second_header) { '.accordion:nth-child(2) .accordion-header' }
    let(:third_header) { '.accordion:nth-child(3) .accordion-header' }
    let(:first_content) { '[data-accordion-target="content"]:nth-of-type(1)' }
    let(:expand_all_btn) { '[data-action="click->accordion#expand_all"]' }
    let(:collapse_all_btn) { '[data-action="click->accordion#collapse_all"]' }

    # Use nth-child selectors scoped to the accordion demo area
    def accordion_content(index)
      all('[data-accordion-target="content"]', visible: :all)[index]
    end

    def accordion_icon(index)
      all('[data-accordion-target="icon"]')[index]
    end

    it 'all panels are collapsed initially' do
      contents = all('[data-accordion-target="content"]', visible: :all)
      contents.each do |content|
        expect(content[:class]).not_to include('accordion-content--open')
      end
    end

    it 'opens a panel when clicking its header' do
      # Click first accordion header
      stable_click('[data-accordion-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      content = accordion_content(0)
      expect(content[:class]).to include('accordion-content--open')
    end

    it 'closes a panel when clicking its header again' do
      # Open
      stable_click('[data-accordion-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      # Close
      stable_click('[data-accordion-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      content = accordion_content(0)
      expect(content[:class]).not_to include('accordion-content--open')
    end

    it 'toggles icon between + and minus' do
      icon = accordion_icon(0)
      expect(icon.text).to eq('+')

      stable_click('[data-accordion-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      icon = accordion_icon(0)
      expect(icon.text).to eq("\u2212")
    end

    it 'expands all panels with Expand All button' do
      stable_click(expand_all_btn)
      sleep 0.3
      wait_for_dom_stable

      contents = all('[data-accordion-target="content"]', visible: :all)
      contents.each do |content|
        expect(content[:class]).to include('accordion-content--open')
      end
    end

    it 'collapses all panels with Collapse All button' do
      # First expand all
      stable_click(expand_all_btn)
      sleep 0.3
      wait_for_dom_stable

      # Then collapse all
      stable_click(collapse_all_btn)
      sleep 0.3
      wait_for_dom_stable

      contents = all('[data-accordion-target="content"]', visible: :all)
      contents.each do |content|
        expect(content[:class]).not_to include('accordion-content--open')
      end
    end

    it 'allows multiple panels open when allow-multiple is true' do
      # Open first panel
      stable_click('[data-accordion-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      # Open second panel
      stable_click('[data-accordion-index-param="1"]')
      sleep 0.3
      wait_for_dom_stable

      # Both should be open
      expect(accordion_content(0)[:class]).to include('accordion-content--open')
      expect(accordion_content(1)[:class]).to include('accordion-content--open')
    end
  end

  describe 'Dropdown Controller' do
    let(:dropdown_btn) { '[data-dropdown-target="button"]' }
    let(:dropdown_menu) { '[data-dropdown-target="menu"]' }

    it 'menu is hidden initially' do
      menu = find(dropdown_menu, visible: :all)
      expect(menu[:class]).not_to include('dropdown-menu--open')
    end

    it 'opens menu when clicking button' do
      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      menu = find(dropdown_menu, visible: :all)
      expect(menu[:class]).to include('dropdown-menu--open')
    end

    it 'closes menu when clicking button again' do
      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      menu = find(dropdown_menu, visible: :all)
      expect(menu[:class]).not_to include('dropdown-menu--open')
    end

    it 'closes menu when clicking outside' do
      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      # Click on the page header (outside dropdown)
      stable_click('header h1')
      sleep 0.3
      wait_for_dom_stable

      menu = find(dropdown_menu, visible: :all)
      expect(menu[:class]).not_to include('dropdown-menu--open')
    end

    it 'closes menu when clicking a menu item' do
      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      # Click a dropdown item
      stable_click('.dropdown-item:first-child')
      sleep 0.3
      wait_for_dom_stable

      menu = find(dropdown_menu, visible: :all)
      expect(menu[:class]).not_to include('dropdown-menu--open')
    end

    it 'displays all menu items' do
      stable_click(dropdown_btn)
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.dropdown-item', text: 'Profile')
      expect(page).to have_css('.dropdown-item', text: 'Settings')
      expect(page).to have_css('.dropdown-item', text: 'Help')
      expect(page).to have_css('.dropdown-item', text: 'Sign Out')
    end
  end

  describe 'Toggle Controller' do
    def toggle_switch(index)
      all('[data-toggle-target="switch"]')[index]
    end

    def toggle_status(index)
      all('[data-toggle-target="status"]')[index]
    end

    it 'all toggles are off initially' do
      switches = all('[data-toggle-target="switch"]')
      switches.each do |sw|
        expect(sw[:class]).not_to include('toggle-switch--on')
      end
    end

    it 'displays default status text' do
      expect(toggle_status(0).text).to eq('OFF')
      expect(toggle_status(1).text).to eq('Disabled')
      expect(toggle_status(2).text).to eq('Hidden')
    end

    it 'toggles on when clicking switch' do
      toggle_switch(0).click
      sleep 0.3
      wait_for_dom_stable

      expect(toggle_switch(0)[:class]).to include('toggle-switch--on')
      expect(toggle_status(0).text).to eq('ON')
    end

    it 'toggles off when clicking again' do
      toggle_switch(0).click
      sleep 0.3
      wait_for_dom_stable

      toggle_switch(0).click
      sleep 0.3
      wait_for_dom_stable

      expect(toggle_switch(0)[:class]).not_to include('toggle-switch--on')
      expect(toggle_status(0).text).to eq('OFF')
    end

    it 'displays custom label text for Dark Mode toggle' do
      toggle_switch(1).click
      sleep 0.3
      wait_for_dom_stable

      expect(toggle_status(1).text).to eq('Enabled')

      toggle_switch(1).click
      sleep 0.3
      wait_for_dom_stable

      expect(toggle_status(1).text).to eq('Disabled')
    end

    it 'reveals content when Show Details toggle is on' do
      content = find('[data-toggle-target="content"]', visible: :all)
      expect(content).not_to be_visible

      toggle_switch(2).click
      sleep 0.3
      wait_for_dom_stable

      content = find('[data-toggle-target="content"]', visible: :all)
      expect(content).to be_visible
    end

    it 'hides content when Show Details toggle is off' do
      # Turn on
      toggle_switch(2).click
      sleep 0.3
      wait_for_dom_stable

      # Turn off
      toggle_switch(2).click
      sleep 0.3
      wait_for_dom_stable

      content = find('[data-toggle-target="content"]', visible: :all)
      expect(content).not_to be_visible
    end
  end

  describe 'Tooltip Controller' do
    let(:top_btn) { '.tooltip-wrapper:nth-child(1)' }
    let(:bottom_btn) { '.tooltip-wrapper:nth-child(2)' }
    let(:left_btn) { '.tooltip-wrapper:nth-child(3)' }
    let(:right_btn) { '.tooltip-wrapper:nth-child(4)' }

    it 'no tooltips visible initially' do
      expect(page).not_to have_css('.tooltip')
    end

    it 'shows tooltip on hover' do
      find(top_btn).hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.tooltip', text: 'Tooltip on top')
    end

    it 'hides tooltip when mouse leaves' do
      find(top_btn).hover
      sleep 0.3
      wait_for_dom_stable

      # Move mouse away
      find('header h1').hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).not_to have_css('.tooltip')
    end

    it 'shows tooltip with correct position class - top' do
      find(top_btn).hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.tooltip.tooltip--top')
    end

    it 'shows tooltip with correct position class - bottom' do
      find(bottom_btn).hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.tooltip.tooltip--bottom')
    end

    it 'shows tooltip with correct position class - left' do
      find(left_btn).hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.tooltip.tooltip--left')
    end

    it 'shows tooltip with correct position class - right' do
      find(right_btn).hover
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_css('.tooltip.tooltip--right')
    end
  end

  describe 'Tabs Controller' do
    let(:tabs) { '[data-tabs-target="tab"]' }
    let(:panels) { '[data-tabs-target="panel"]' }

    def tab(index)
      all(tabs)[index]
    end

    def panel(index)
      all(panels, visible: :all)[index]
    end

    it 'first tab is active initially' do
      expect(tab(0)[:class]).to include('tabs-tab--active')
      expect(tab(0)[:'aria-selected']).to eq('true')
    end

    it 'first panel is visible initially' do
      expect(panel(0)[:class]).to include('tabs-panel--active')
      expect(panel(0)[:'aria-hidden']).to eq('false')
    end

    it 'other tabs are inactive initially' do
      expect(tab(1)[:class]).not_to include('tabs-tab--active')
      expect(tab(1)[:'aria-selected']).to eq('false')
      expect(tab(2)[:class]).not_to include('tabs-tab--active')
      expect(tab(2)[:'aria-selected']).to eq('false')
    end

    it 'other panels are hidden initially' do
      expect(panel(1)[:class]).not_to include('tabs-panel--active')
      expect(panel(1)[:'aria-hidden']).to eq('true')
      expect(panel(2)[:class]).not_to include('tabs-panel--active')
      expect(panel(2)[:'aria-hidden']).to eq('true')
    end

    it 'switches to second tab when clicked' do
      stable_click('[data-tabs-index-param="1"]')
      sleep 0.3
      wait_for_dom_stable

      # Second tab active
      expect(tab(1)[:class]).to include('tabs-tab--active')
      expect(tab(1)[:'aria-selected']).to eq('true')

      # Second panel visible
      expect(panel(1)[:class]).to include('tabs-panel--active')
      expect(panel(1)[:'aria-hidden']).to eq('false')

      # First tab/panel inactive
      expect(tab(0)[:class]).not_to include('tabs-tab--active')
      expect(panel(0)[:class]).not_to include('tabs-panel--active')
    end

    it 'switches to third tab when clicked' do
      stable_click('[data-tabs-index-param="2"]')
      sleep 0.3
      wait_for_dom_stable

      expect(tab(2)[:class]).to include('tabs-tab--active')
      expect(panel(2)[:class]).to include('tabs-panel--active')
    end

    it 'switches back to first tab' do
      # Go to second tab
      stable_click('[data-tabs-index-param="1"]')
      sleep 0.3
      wait_for_dom_stable

      # Go back to first tab
      stable_click('[data-tabs-index-param="0"]')
      sleep 0.3
      wait_for_dom_stable

      expect(tab(0)[:class]).to include('tabs-tab--active')
      expect(panel(0)[:class]).to include('tabs-panel--active')
    end

    it 'displays correct panel content' do
      expect(page).to have_css('.tabs-panel--active h3', text: 'Overview')

      stable_click('[data-tabs-index-param="1"]')
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_css('.tabs-panel--active h3', text: 'Features')

      stable_click('[data-tabs-index-param="2"]')
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_css('.tabs-panel--active h3', text: 'Usage')
    end

    it 'updates aria attributes correctly' do
      stable_click('[data-tabs-index-param="1"]')
      sleep 0.3
      wait_for_dom_stable

      # Check tabindex
      expect(tab(1)[:'tabindex']).to eq('0')
      expect(tab(0)[:'tabindex']).to eq('-1')
      expect(tab(2)[:'tabindex']).to eq('-1')
    end
  end
end
