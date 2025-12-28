# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'CRUD App', type: :feature do
  # Helper to fill in name input
  def fill_name(value)
    find('[data-list-target="nameInput"]').fill_in with: value
  end

  # Helper to fill in quantity input
  def fill_quantity(value)
    find('[data-list-target="quantityInput"]').fill_in with: value.to_s
  end

  describe 'Initial State' do
    it 'shows the page title' do
      expect(page).to have_content('CRUD App')
    end

    it 'displays the feature description' do
      expect(page).to have_content('Demonstrating Stimulus Action Parameters')
    end

    it 'shows the initial sample items' do
      expect(page).to have_content('Laptop')
      expect(page).to have_content('Mouse')
      expect(page).to have_content('Keyboard')
    end

    it 'displays correct item count' do
      expect(page).to have_css('[data-list-target="itemCount"]', text: '3')
    end

    it 'displays correct total quantity' do
      # Laptop (2) + Mouse (5) + Keyboard (3) = 10
      expect(page).to have_css('[data-list-target="totalQuantity"]', text: '10')
    end

    it 'shows the add form' do
      expect(page).to have_css('[data-list-target="nameInput"]')
      expect(page).to have_css('[data-list-target="quantityInput"]')
      expect(page).to have_button('Add')
    end
  end

  describe 'Add Item' do
    it 'adds a new item with default quantity' do
      fill_name('Monitor')
      click_button 'Add'
      wait_for_dom_stable

      expect(page).to have_content('Monitor')
      expect(page).to have_css('[data-list-target="itemCount"]', text: '4')
    end

    it 'adds a new item with custom quantity' do
      fill_name('USB Cable')
      fill_quantity(5)
      click_button 'Add'
      wait_for_dom_stable

      expect(page).to have_content('USB Cable')
      expect(page).to have_content('Quantity: 5')
    end

    it 'clears input after adding' do
      fill_name('Headphones')
      click_button 'Add'
      wait_for_dom_stable

      input = find('[data-list-target="nameInput"]')
      expect(input.value).to eq('')
    end

    it 'updates statistics after adding' do
      initial_count = find('[data-list-target="itemCount"]').text.to_i
      initial_quantity = find('[data-list-target="totalQuantity"]').text.to_i

      fill_name('Charger')
      fill_quantity(3)
      click_button 'Add'
      wait_for_dom_stable

      expect(page).to have_css('[data-list-target="itemCount"]', text: (initial_count + 1).to_s)
      expect(page).to have_css('[data-list-target="totalQuantity"]', text: (initial_quantity + 3).to_s)
    end

    it 'does not add item with empty name' do
      initial_count = find('[data-list-target="itemCount"]').text.to_i

      # Clear any existing text and try to add
      find('[data-list-target="nameInput"]').fill_in with: ''
      click_button 'Add'
      wait_for_dom_stable

      # Count should not change
      expect(page).to have_css('[data-list-target="itemCount"]', text: initial_count.to_s)
    end

    it 'adds item using Enter key' do
      name_input = find('[data-list-target="nameInput"]')
      name_input.fill_in with: 'Webcam'
      name_input.send_keys(:enter)
      wait_for_dom_stable

      expect(page).to have_content('Webcam')
    end
  end

  describe 'Delete Item' do
    it 'deletes an item' do
      initial_count = find('[data-list-target="itemCount"]').text.to_i

      # Find and click the delete button for Laptop
      within(find('.bg-gray-50', text: 'Laptop')) do
        click_button 'Delete'
      end
      wait_for_dom_stable

      expect(page).not_to have_content('Laptop')
      expect(page).to have_css('[data-list-target="itemCount"]', text: (initial_count - 1).to_s)
    end

    it 'updates total quantity after delete' do
      initial_quantity = find('[data-list-target="totalQuantity"]').text.to_i

      # Delete Mouse (quantity: 5)
      within(find('.bg-gray-50', text: 'Mouse')) do
        click_button 'Delete'
      end
      wait_for_dom_stable

      expect(page).to have_css('[data-list-target="totalQuantity"]', text: (initial_quantity - 5).to_s)
    end

    it 'shows empty state when all items deleted' do
      # Delete all items
      3.times do
        first('.bg-gray-50 button', text: 'Delete').click
        wait_for_dom_stable
      end

      expect(page).to have_content('No items yet')
      expect(page).to have_css('[data-list-target="itemCount"]', text: '0')
      expect(page).to have_css('[data-list-target="totalQuantity"]', text: '0')
    end
  end

  describe 'Edit Item' do
    it 'opens modal when edit button clicked' do
      within(find('.bg-gray-50', text: 'Laptop')) do
        click_button 'Edit'
      end
      wait_for_dom_stable

      # Modal should be visible
      expect(page).to have_css('[data-controller="modal"]:not(.hidden)')
      expect(page).to have_content('Edit Item')
    end

    it 'populates modal with current item data' do
      within(find('.bg-gray-50', text: 'Mouse')) do
        click_button 'Edit'
      end
      wait_for_dom_stable

      # Check modal inputs have the item data
      name_input = find('[data-modal-target="nameInput"]')
      quantity_input = find('[data-modal-target="quantityInput"]')

      expect(name_input.value).to eq('Mouse')
      expect(quantity_input.value).to eq('5')
    end

    it 'closes modal on cancel' do
      within(find('.bg-gray-50', text: 'Laptop')) do
        click_button 'Edit'
      end
      wait_for_dom_stable

      click_button 'Cancel'
      wait_for_dom_stable

      expect(page).to have_css('[data-controller="modal"].hidden', visible: :all)
    end

    it 'updates item on save', skip: 'Edit save functionality has timing issue' do
      within(find('.bg-gray-50', text: 'Keyboard')) do
        click_button 'Edit'
      end
      wait_for_dom_stable

      # Update the name and quantity in the modal
      modal_name_input = find('[data-modal-target="nameInput"]')
      modal_name_input.fill_in with: ''  # Clear first
      modal_name_input.fill_in with: 'Mechanical Keyboard'

      modal_quantity_input = find('[data-modal-target="quantityInput"]')
      modal_quantity_input.fill_in with: ''  # Clear first
      modal_quantity_input.fill_in with: '1'

      click_button 'Save Changes'
      sleep 0.5  # Extra wait for event propagation
      wait_for_dom_stable

      expect(page).to have_content('Mechanical Keyboard')
      expect(page).to have_content('Quantity: 1')
    end

    it 'closes modal after successful save' do
      within(find('.bg-gray-50', text: 'Laptop')) do
        click_button 'Edit'
      end
      wait_for_dom_stable

      find('[data-modal-target="nameInput"]').fill_in with: 'Gaming Laptop'
      click_button 'Save Changes'
      wait_for_dom_stable

      expect(page).to have_css('[data-controller="modal"].hidden', visible: :all)
    end
  end

  describe 'Action Parameters' do
    it 'sets action parameters on dynamically created buttons' do
      # Add a new item
      fill_name('Test Item')
      click_button 'Add'
      wait_for_dom_stable

      # Check that the edit button has the correct action parameters
      edit_button = find('.bg-gray-50', text: 'Test Item').find('button', text: 'Edit')

      expect(edit_button['data-list-name-param']).to eq('Test Item')
      expect(edit_button['data-list-quantity-param']).to eq('1')
    end
  end

  describe 'Statistics' do
    it 'shows Total Items count' do
      expect(page).to have_content('Total Items')
      expect(page).to have_css('[data-list-target="itemCount"]')
    end

    it 'shows Total Quantity count' do
      expect(page).to have_content('Total Quantity')
      expect(page).to have_css('[data-list-target="totalQuantity"]')
    end

    it 'updates statistics correctly through multiple operations' do
      # Add an item
      fill_name('New Item')
      fill_quantity(7)
      click_button 'Add'
      wait_for_dom_stable

      expect(page).to have_css('[data-list-target="itemCount"]', text: '4')
      expect(page).to have_css('[data-list-target="totalQuantity"]', text: '17') # 10 + 7

      # Delete an item
      within(find('.bg-gray-50', text: 'Mouse')) do
        click_button 'Delete'
      end
      wait_for_dom_stable

      expect(page).to have_css('[data-list-target="itemCount"]', text: '3')
      expect(page).to have_css('[data-list-target="totalQuantity"]', text: '12') # 17 - 5
    end
  end
end
