# backtick_javascript: true

# Demonstrates Turbo Streams actions from Ruby
class TurboStreamController < StimulusController
  include StimulusHelpers

  self.targets = ["container", "count"]
  self.values = { counter: :number }

  def initialize
    super
    @counter_value = 0
  end

  def connect
    puts "TurboStream controller connected!"
    update_counter
  end

  # Turbo Stream: APPEND action
  def append_item
    self.counter_value += 1
    item_html = "<div class='stream-item' id='item_#{counter_value}'>Item #{counter_value} (appended)</div>"

    puts "Appending item #{counter_value}"
    turbo_stream_action('append', 'stream-container', item_html)
    update_counter
  end

  # Turbo Stream: PREPEND action
  def prepend_item
    self.counter_value += 1
    item_html = "<div class='stream-item' id='item_#{counter_value}'>Item #{counter_value} (prepended)</div>"

    puts "Prepending item #{counter_value}"
    turbo_stream_action('prepend', 'stream-container', item_html)
    update_counter
  end

  # Turbo Stream: UPDATE action (updates content, preserves wrapper)
  def update_status
    timestamp = `new Date().toLocaleTimeString()`
    puts "Updating status with timestamp: #{timestamp}"

    update_html = "<p>Last updated: #{timestamp}</p>"
    turbo_stream_action('update', 'status-box', update_html)
  end

  # Turbo Stream: REPLACE action (replaces entire element)
  def replace_content
    timestamp = `new Date().toLocaleTimeString()`
    puts "Replacing content box"

    replace_html = "<div id='content-box' class='demo-box'><h4>Replaced at #{timestamp}</h4><p>This entire box was replaced</p></div>"
    turbo_stream_action('replace', 'content-box', replace_html)
  end

  # Turbo Stream: REMOVE action
  def remove_last_item
    puts "Removing last item"

    container = query('#stream-container')
    items = `#{container}.querySelectorAll('.stream-item')`
    length = `#{items}.length`

    if `#{length} > 0`
      last_item = `#{items}[#{length} - 1]`
      item_id = get_attr(last_item, 'id')
      turbo_stream_action('remove', item_id, '')
      puts "Removed item: #{item_id}"
    else
      puts "No items to remove"
    end

    self.counter_value -= 1 if counter_value > 0
    update_counter
  end

  # Turbo Stream: BEFORE action
  def insert_before
    puts "Inserting element before target"
    html = "<div class='stream-item inserted'>Inserted BEFORE</div>"
    turbo_stream_action('before', 'insert-marker', html)
  end

  # Turbo Stream: AFTER action
  def insert_after
    puts "Inserting element after target"
    html = "<div class='stream-item inserted'>Inserted AFTER</div>"
    turbo_stream_action('after', 'insert-marker', html)
  end

  # Clear all items
  def clear_all
    puts "Clearing all items"
    turbo_stream_action('update', 'stream-container', '')

    self.counter_value = 0
    update_counter
  end

  private

  def turbo_stream_action(action, target, html)
    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', #{action});
      stream.setAttribute('target', #{target});

      const template = document.createElement('template');
      template.innerHTML = #{html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `
  end

  def update_counter
    count_el = query('#item-count')
    set_text(count_el, counter_value.to_s) if count_el
  end
end
