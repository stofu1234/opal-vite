# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'API Integration Example', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'API Integration Example')
    end

    it 'displays the subtitle' do
      expect(page).to have_css('.subtitle', text: 'Fetch API with Ruby')
    end

    it 'displays the users section' do
      expect(page).to have_css('h2', text: 'Users from JSONPlaceholder API')
    end

    it 'displays the reload button' do
      expect(page).to have_css('.reload-btn', text: 'Reload')
    end

    it 'displays the info card' do
      expect(page).to have_css('.info-card h3', text: 'About This Example')
      expect(page).to have_css('.info-card', text: 'API Integration')
    end

    it 'displays the footer' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Vite')
    end
  end

  describe 'users list loading' do
    it 'loads users from API on page load' do
      wait_for_users_loaded
      expect(page).to have_css('.user-card', minimum: 1)
    end

    it 'displays multiple users' do
      wait_for_users_loaded
      # JSONPlaceholder returns 10 users
      expect(page).to have_css('.user-card', count: 10)
    end

    it 'displays user names' do
      wait_for_users_loaded
      # Check that at least one user has a name displayed
      expect(page).to have_css('.user-card h3')
    end

    it 'hides loading indicator after load' do
      wait_for_users_loaded
      loading = find('[data-users-target="loading"]', visible: :all)
      expect(loading[:style]).to include('display: none')
    end
  end

  describe 'user card content' do
    before do
      wait_for_users_loaded
    end

    it 'displays user email' do
      first_card = first('.user-card')
      expect(first_card).to have_css('.user-email')
    end

    it 'displays user company' do
      first_card = first('.user-card')
      # Check for company detail
      expect(first_card).to have_css('.detail-label', text: 'Company:')
    end

    it 'displays user name' do
      first_card = first('.user-card')
      expect(first_card).to have_css('h3')
    end
  end

  describe 'reload functionality' do
    before do
      wait_for_users_loaded
    end

    it 'reloads users when reload button is clicked' do
      initial_user_count = all('.user-card').count

      stable_click('.reload-btn')
      sleep 0.5

      # Wait for reload to complete
      wait_for_users_loaded

      # Should still have users after reload
      expect(all('.user-card').count).to eq(initial_user_count)
    end
  end

  describe 'user modal' do
    before do
      wait_for_users_loaded
    end

    it 'has modal hidden initially' do
      modal = find('.modal', visible: :all)
      expect(modal[:class]).not_to include('active')
    end

    it 'opens modal when clicking user card' do
      # Click the first user card
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable

      # Modal should become active
      expect(page).to have_css('.modal.active', wait: 10)
    end

    it 'displays user details in modal' do
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable

      # Wait for modal to open
      expect(page).to have_css('.modal.active', wait: 10)

      # Check for user info fields
      expect(page).to have_css('[data-user-modal-target="userName"]')
      expect(page).to have_css('[data-user-modal-target="userEmail"]')
    end

    it 'displays user posts in modal' do
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable

      expect(page).to have_css('.modal.active', wait: 10)
      expect(page).to have_css('h4', text: 'Recent Posts')
      expect(page).to have_css('[data-user-modal-target="postsList"]')
    end

    it 'closes modal when clicking close button' do
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable

      expect(page).to have_css('.modal.active', wait: 10)

      stable_click('.modal-close')
      sleep 0.5
      wait_for_dom_stable

      modal = find('.modal', visible: :all)
      expect(modal[:class]).not_to include('active')
    end

    it 'closes modal when pressing Escape' do
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable

      expect(page).to have_css('.modal.active', wait: 10)

      # Press Escape
      page.send_keys(:escape)
      sleep 0.5
      wait_for_dom_stable

      modal = find('.modal', visible: :all)
      expect(modal[:class]).not_to include('active')
    end
  end

  describe 'modal content' do
    before do
      wait_for_users_loaded
      first('.user-card').click
      sleep 1.5
      wait_for_dom_stable
      expect(page).to have_css('.modal.active', wait: 10)
    end

    it 'displays user name in modal header' do
      name = find('[data-user-modal-target="userName"]').text
      expect(name.length).to be > 0
    end

    it 'displays user email' do
      email = find('[data-user-modal-target="userEmail"]').text
      expect(email).to match(/@/)
    end

    it 'displays user company' do
      company = find('[data-user-modal-target="userCompany"]').text
      expect(company.length).to be > 0
    end

    it 'displays user address' do
      address = find('[data-user-modal-target="userAddress"]').text
      expect(address.length).to be > 0
    end

    it 'displays user phone' do
      phone = find('[data-user-modal-target="userPhone"]').text
      expect(phone.length).to be > 0
    end

    it 'displays user website' do
      website = find('[data-user-modal-target="userWebsite"]').text
      expect(website.length).to be > 0
    end
  end

  describe 'info section' do
    it 'describes API integration features' do
      expect(page).to have_css('.info-card li', text: /API Integration/i)
    end

    it 'describes loading states' do
      expect(page).to have_css('.info-card li', text: /Loading States/i)
    end

    it 'describes error handling' do
      expect(page).to have_css('.info-card li', text: /Error Handling/i)
    end

    it 'links to JSONPlaceholder' do
      expect(page).to have_link('JSONPlaceholder', href: 'https://jsonplaceholder.typicode.com')
    end
  end
end
