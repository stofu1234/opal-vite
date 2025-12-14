# backtick_javascript: true

# Demonstrates Turbo Streams actions from Ruby
class TurboStreamController < StimulusController
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

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'append');
      stream.setAttribute('target', 'stream-container');

      const template = document.createElement('template');
      template.innerHTML = #{item_html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `

    update_counter
  end

  # Turbo Stream: PREPEND action
  def prepend_item
    self.counter_value += 1
    item_html = "<div class='stream-item' id='item_#{counter_value}'>Item #{counter_value} (prepended)</div>"

    puts "Prepending item #{counter_value}"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'prepend');
      stream.setAttribute('target', 'stream-container');

      const template = document.createElement('template');
      template.innerHTML = #{item_html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `

    update_counter
  end

  # Turbo Stream: UPDATE action (updates content, preserves wrapper)
  def update_status
    timestamp = `new Date().toLocaleTimeString()`

    puts "Updating status with timestamp: #{timestamp}"

    update_html = "<p>Last updated: #{timestamp}</p>"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'update');
      stream.setAttribute('target', 'status-box');

      const template = document.createElement('template');
      template.innerHTML = #{update_html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `
  end

  # Turbo Stream: REPLACE action (replaces entire element)
  def replace_content
    timestamp = `new Date().toLocaleTimeString()`

    puts "Replacing content box"

    replace_html = "<div id='content-box' class='demo-box'><h4>Replaced at #{timestamp}</h4><p>This entire box was replaced</p></div>"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'replace');
      stream.setAttribute('target', 'content-box');

      const template = document.createElement('template');
      template.innerHTML = #{replace_html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `
  end

  # Turbo Stream: REMOVE action
  def remove_last_item
    puts "Removing last item"

    `
      const container = document.getElementById('stream-container');
      const items = container.querySelectorAll('.stream-item');
      if (items.length > 0) {
        const lastItem = items[items.length - 1];
        const itemId = lastItem.id;

        const stream = document.createElement('turbo-stream');
        stream.setAttribute('action', 'remove');
        stream.setAttribute('target', itemId);

        document.body.appendChild(stream);

        console.log('Removed item:', itemId);
      } else {
        console.log('No items to remove');
      }
    `

    self.counter_value -= 1 if counter_value > 0
    update_counter
  end

  # Turbo Stream: BEFORE action
  def insert_before
    puts "Inserting element before target"

    html = "<div class='stream-item inserted'>Inserted BEFORE</div>"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'before');
      stream.setAttribute('target', 'insert-marker');

      const template = document.createElement('template');
      template.innerHTML = #{html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `
  end

  # Turbo Stream: AFTER action
  def insert_after
    puts "Inserting element after target"

    html = "<div class='stream-item inserted'>Inserted AFTER</div>"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'after');
      stream.setAttribute('target', 'insert-marker');

      const template = document.createElement('template');
      template.innerHTML = #{html};
      stream.appendChild(template);

      document.body.appendChild(stream);
    `
  end

  # Clear all items
  def clear_all
    puts "Clearing all items"

    `
      const stream = document.createElement('turbo-stream');
      stream.setAttribute('action', 'update');
      stream.setAttribute('target', 'stream-container');

      const template = document.createElement('template');
      template.innerHTML = '';
      stream.appendChild(template);

      document.body.appendChild(stream);
    `

    self.counter_value = 0
    update_counter
  end

  private

  def update_counter
    `
      const countElement = document.getElementById('item-count');
      if (countElement) {
        countElement.textContent = #{counter_value};
      }
    `
  end
end
