# backtick_javascript: true

# ModalController - Manages edit modal dialog
#
# This controller handles the modal for editing items
#
class ModalController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["overlay", "content", "title", "nameInput", "quantityInput"]

  def connect
    puts "ModalController connected"

    # Store element reference for use in callbacks
    # Note: Must use JavaScript this.element, not a Ruby method
    controller_element = `this.element`

    # Listen for open-modal event
    on_window_event('open-modal') do |e|
      detail = `#{e}.detail`
      id = `#{detail}.id`
      name = `#{detail}.name`
      quantity = `#{detail}.quantity`

      # Store item ID for save as Ruby instance variable
      @current_item_id = id

      # Set form values using the captured element reference
      name_input = `#{controller_element}.querySelector('[data-modal-target="nameInput"]')`
      quantity_input = `#{controller_element}.querySelector('[data-modal-target="quantityInput"]')`

      `#{name_input}.value = #{name}` if `#{name_input}`
      `#{quantity_input}.value = #{quantity}` if `#{quantity_input}`

      # Open modal
      open_modal
    end
  end

  # Action: Close modal
  def close
    close_modal
  end

  # Action: Close on overlay click
  def close_on_overlay
    close_modal
  end

  # Action: Stop propagation (prevent overlay click on content)
  def stop_propagation
    `event.stopPropagation()`
  end

  # Action: Save changes
  def save
    # Get input values directly using JavaScript for reliability
    # Note: 'this' works in action methods (called from Stimulus actions)
    name = `this.nameInputTarget.value`
    name = `#{name}.trim()` if name

    if `#{name} === '' || #{name} == null || typeof #{name} === 'undefined'`
      puts "Error: Item name cannot be empty"
      return
    end

    quantity_str = `this.quantityInputTarget.value`
    quantity = parse_int(quantity_str)
    quantity = 1 if is_nan?(quantity) || quantity < 1

    # Get stored item ID from Ruby instance variable
    item_id = @current_item_id

    puts "Saving item #{item_id}: #{name} (quantity: #{quantity})"

    # Dispatch update event
    dispatch_window_event('item-updated', {
      id: item_id,
      name: name,
      quantity: quantity
    })

    close_modal
  end

  private

  def open_modal
    # Show modal by removing hidden class
    element_remove_class('hidden')

    # Focus name input after a short delay
    set_timeout(100) do
      target_focus(:nameInput) if has_target?(:nameInput)
    end
  end

  def close_modal
    # Hide modal
    element_add_class('hidden')

    # Clear current item ID
    @current_item_id = nil
  end
end
