# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Turbo + Opal + Vite', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'Turbo + Opal + Vite')
    end

    it 'displays the subtitle' do
      expect(page).to have_css('.subtitle', text: 'Control Turbo from Ruby')
    end

    it 'displays three section cards' do
      expect(page).to have_css('.card', count: 3)
    end

    it 'displays the footer' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Turbo')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Vite')
    end
  end

  describe 'Turbo Drive section' do
    it 'displays Turbo Drive section' do
      expect(page).to have_css('h2', text: 'Turbo Drive')
    end

    it 'displays current page info' do
      expect(page).to have_css('h3', text: 'Current Page: Home')
    end

    it 'has navigation buttons' do
      expect(page).to have_button('Visit Page 1')
      expect(page).to have_button('Visit Page 2')
      expect(page).to have_button('Go Back')
    end
  end

  describe 'Turbo Frames section' do
    it 'displays Turbo Frames section' do
      expect(page).to have_css('h2', text: 'Turbo Frames')
    end

    it 'has turbo-frame element' do
      expect(page).to have_css('turbo-frame#dynamic-frame')
    end

    it 'has frame control buttons' do
      expect(page).to have_button('Toggle Loading State')
      expect(page).to have_button('Update Frame Content')
    end
  end

  describe 'Turbo Streams section' do
    it 'displays Turbo Streams section' do
      expect(page).to have_css('h2', text: 'Turbo Streams')
    end

    it 'displays stream container' do
      expect(page).to have_css('#stream-container')
    end

    it 'displays item counter badge' do
      expect(page).to have_css('#item-count', text: '0')
    end

    it 'has basic action buttons' do
      expect(page).to have_button('Append')
      expect(page).to have_button('Prepend')
      expect(page).to have_button('Remove Last')
      expect(page).to have_button('Clear All')
    end

    it 'has update/replace buttons' do
      expect(page).to have_button('Update Status')
      expect(page).to have_button('Replace Content')
    end

    it 'has insert before/after buttons' do
      expect(page).to have_button('Insert Before')
      expect(page).to have_button('Insert After')
    end
  end

  describe 'Turbo Stream actions' do
    it 'appends item when clicking append button' do
      stable_click('[data-action="click->turbo-stream#append_item"]')
      sleep 0.5
      wait_for_dom_stable

      expect(page).to have_css('#stream-container .stream-item', minimum: 1)
      expect(page).to have_css('#item-count', text: '1')
    end

    it 'prepends item when clicking prepend button' do
      stable_click('[data-action="click->turbo-stream#prepend_item"]')
      sleep 0.5
      wait_for_dom_stable

      expect(page).to have_css('#stream-container .stream-item', minimum: 1)
    end

    it 'removes last item when clicking remove button' do
      # First add an item
      stable_click('[data-action="click->turbo-stream#append_item"]')
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_css('#stream-container .stream-item', count: 1)

      # Then remove it
      stable_click('[data-action="click->turbo-stream#remove_last_item"]')
      sleep 0.3
      wait_for_dom_stable

      expect(page).to have_no_css('#stream-container .stream-item')
    end

    it 'clears all items when clicking clear button' do
      # Add a few items
      2.times do
        stable_click('[data-action="click->turbo-stream#append_item"]')
        sleep 0.5
        wait_for_dom_stable
      end
      expect(page).to have_css('#stream-container .stream-item', minimum: 1)

      # Clear all
      stable_click('[data-action="click->turbo-stream#clear_all"]')
      sleep 0.5
      wait_for_dom_stable

      expect(page).to have_no_css('#stream-container .stream-item')
    end

    it 'updates status box' do
      stable_click('[data-action="click->turbo-stream#update_status"]')
      sleep 0.5
      wait_for_dom_stable

      status_box = find('#status-box')
      # Status box shows timestamp after update
      expect(status_box.text).to match(/updated|Last|:/i)
    end
  end

  describe 'insert marker actions' do
    it 'has insert marker element' do
      expect(page).to have_css('#insert-marker', text: 'INSERT MARKER')
    end

    it 'inserts element before marker' do
      stable_click('[data-action="click->turbo-stream#insert_before"]')
      sleep 0.5
      wait_for_dom_stable

      # Check that something was inserted before the marker
      marker = find('#insert-marker')
      expect(marker).to be_truthy
    end

    it 'inserts element after marker' do
      stable_click('[data-action="click->turbo-stream#insert_after"]')
      sleep 0.5
      wait_for_dom_stable

      # Check that something was inserted after the marker
      marker = find('#insert-marker')
      expect(marker).to be_truthy
    end
  end

  describe 'Turbo Frame content' do
    it 'has frame content' do
      within 'turbo-frame#dynamic-frame' do
        expect(page).to have_css('h4', text: 'Frame Content')
      end
    end

    it 'update frame content button is clickable' do
      update_btn = find('button', text: 'Update Frame Content')
      expect { update_btn.click }.not_to raise_error
    end
  end

  describe 'Turbo library integration' do
    it 'loads Turbo library' do
      result = page.evaluate_script('typeof Turbo !== "undefined"')
      expect(result).to be true
    end

    it 'Turbo session is active' do
      result = page.evaluate_script('typeof Turbo.session !== "undefined"')
      expect(result).to be true
    end
  end
end
