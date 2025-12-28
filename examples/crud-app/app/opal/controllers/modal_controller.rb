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

    # Listen for open-modal event
    on_window_event('open-modal') do |e|
      detail = `#{e}.detail`
      id = `#{detail}.id`
      name = `#{detail}.name`
      quantity = `#{detail}.quantity`

      # Store item ID for save
      `this.currentItemId = #{id}`

      # Set form values
      target_set_value(:nameInput, name) if has_target?(:nameInput)
      target_set_value(:quantityInput, quantity) if has_target?(:quantityInput)

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
    return unless has_target?(:nameInput) && has_target?(:quantityInput)

    name = target_value(:nameInput)
    name = `#{name}.trim()`

    if `#{name} === ''`
      puts "Error: Item name cannot be empty"
      return
    end

    quantity = parse_int(target_value(:quantityInput))
    if is_nan?(quantity) || quantity < 1
      puts "Error: Quantity must be at least 1"
      return
    end

    # Get stored item ID
    item_id = `this.currentItemId`

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
    `this.currentItemId = null`
  end
end
