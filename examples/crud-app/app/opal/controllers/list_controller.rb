# backtick_javascript: true

# ListController - Demonstrates Stimulus Action Parameters
#
# This controller showcases:
# - action_param(:name) - Get action parameter by name
# - action_param_int(:id) - Get integer action parameter
# - has_action_param?(:name) - Check if parameter exists
# - Working with data-[controller]-[name]-param attributes
#
class ListController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["container", "template", "nameInput", "quantityInput", "itemCount", "totalQuantity"]
  self.values = { items: :array }

  def initialize
    super
    @items_value = `[]`
    @next_id = 1
  end

  def connect
    puts "ListController connected"

    # Initialize with sample data
    add_item("Laptop", 2)
    add_item("Mouse", 5)
    add_item("Keyboard", 3)

    render_items

    # Listen for update events from modal
    on_window_event('item-updated') do |e|
      detail = `#{e}.detail`
      id = parse_int(`#{detail}.id`)
      name = `#{detail}.name`
      quantity = parse_int(`#{detail}.quantity`)

      update_item(id, name, quantity)
    end
  end

  # Action: Add new item
  def add
    name = target_value(:nameInput)
    name = `#{name}.trim()`

    if `#{name} === ''`
      puts "Error: Item name cannot be empty"
      return
    end

    quantity = parse_int(target_value(:quantityInput))
    quantity = 1 if is_nan?(quantity) || quantity < 1

    add_item(name, quantity)

    # Clear inputs
    target_set_value(:nameInput, '')
    target_set_value(:quantityInput, '1')
    target_focus(:nameInput)

    render_items
  end

  # Action: Edit item - demonstrates action parameters
  def edit
    # Demonstrate action_param_int for getting integer ID
    id = action_param_int(:id)

    # Demonstrate action_param for getting string values
    name = action_param(:name)

    # Demonstrate has_action_param? for optional parameters
    quantity = if has_action_param?(:quantity)
      action_param_int(:quantity, 1)
    else
      1
    end

    puts "Edit action called with parameters:"
    puts "  id: #{id} (via action_param_int)"
    puts "  name: #{name} (via action_param)"
    puts "  quantity: #{quantity} (via has_action_param? check)"

    # Open modal with item data
    dispatch_window_event('open-modal', {
      id: id,
      name: name,
      quantity: quantity
    })
  end

  # Action: Delete item - demonstrates action parameters
  def delete
    # Use action_param_int to get the ID parameter
    id = action_param_int(:id)

    # Optionally check if parameter exists
    unless has_action_param?(:id)
      puts "Error: No ID parameter provided"
      return
    end

    puts "Delete action called with ID: #{id} (via action_param_int)"

    # Filter out the item with this ID
    items = stimulus_value(:items)
    `#{items} = #{items}.filter(item => item.id !== #{id})`
    set_stimulus_value(:items, items)

    render_items

    # Get item name for confirmation message
    name = action_param(:name) if has_action_param?(:name)
    if name
      puts "Deleted item: #{name}"
    else
      puts "Deleted item with ID: #{id}"
    end
  end

  private

  def add_item(name, quantity)
    items = stimulus_value(:items)

    new_item = `{
      id: #{@next_id},
      name: #{name},
      quantity: #{quantity}
    }`

    `#{items}.push(#{new_item})`
    set_stimulus_value(:items, items)

    @next_id += 1
  end

  def update_item(id, name, quantity)
    items = stimulus_value(:items)

    # Find and update the item
    `
      const item = #{items}.find(item => item.id === #{id});
      if (item) {
        item.name = #{name};
        item.quantity = #{quantity};
      }
    `

    set_stimulus_value(:items, items)
    render_items

    puts "Updated item #{id}: #{name} (quantity: #{quantity})"
  end

  def render_items
    return unless has_target?(:container)
    return unless has_target?(:template)

    items = stimulus_value(:items)
    container = get_target(:container)

    # Clear container
    set_html(container, '')

    # Check if items array is empty
    items_length = `#{items}.length`

    if items_length == 0
      # Show empty state
      set_html(container, '<div class="text-center py-8 text-gray-500">No items yet. Add one above!</div>')
    else
      # Render each item
      `#{items}.forEach((item) => {
        #{render_item(`item`)}
      })`
    end

    # Update statistics
    update_stats
  end

  def render_item(item)
    clone = clone_template(:template)
    element = template_first_child(clone)

    # Extract item data
    item_id = `#{item}.id`
    item_name = `#{item}.name`
    item_quantity = `#{item}.quantity`

    # Set item data in the DOM
    name_el = query_element_in(element, '[data-name]')
    set_text(name_el, item_name) if name_el

    quantity_el = query_element_in(element, '[data-quantity]')
    set_text(quantity_el, item_quantity) if quantity_el

    id_el = query_element_in(element, '[data-id]')
    set_text(id_el, item_id) if id_el

    # Set action parameters on buttons
    edit_btn = query_element_in(element, '[data-action*="edit"]')
    if edit_btn
      # Set action parameters using data-list-[name]-param attributes
      set_attr(edit_btn, 'data-list-id-param', item_id)
      set_attr(edit_btn, 'data-list-name-param', item_name)
      set_attr(edit_btn, 'data-list-quantity-param', item_quantity)
    end

    delete_btn = query_element_in(element, '[data-action*="delete"]')
    if delete_btn
      # Set action parameters for delete
      set_attr(delete_btn, 'data-list-id-param', item_id)
      set_attr(delete_btn, 'data-list-name-param', item_name)
    end

    # Append to container
    container = get_target(:container)
    append_child(container, element)
  end

  def update_stats
    items = stimulus_value(:items)

    # Count items
    item_count = `#{items}.length`
    target_set_text(:itemCount, item_count) if has_target?(:itemCount)

    # Sum quantities
    total_quantity = `#{items}.reduce((sum, item) => sum + item.quantity, 0)`
    target_set_text(:totalQuantity, total_quantity) if has_target?(:totalQuantity)
  end

  # Helper to query within an element
  def query_element_in(element, selector)
    el = `#{element}.querySelector(#{selector})`
    `#{el} === null` ? nil : el
  end
end
