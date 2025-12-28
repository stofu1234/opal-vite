# backtick_javascript: true

# ClipboardDemoController - Demonstrates clipboard and other utilities
#
# Features:
# - Copy to clipboard
# - Read from clipboard
# - Debounce/throttle
# - Set utilities
# - Object utilities
#
class ClipboardDemoController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["copyInput", "pasteOutput", "searchInput", "searchOutput",
                  "arr1", "arr2", "setOutput", "obj1", "obj2", "objOutput"]

  def connect
    puts "ClipboardDemoController connected"
    @search_count = 0
    @throttle_count = 0
  end

  # Action: Copy text to clipboard
  def copy
    text = target_value(:copyInput)
    return if blank?(text)

    copy_to_clipboard(text) do
      console_styled("Copied to clipboard: #{text}", "color: green;")
      show_toast("Copied!")
    end
  end

  # Action: Paste from clipboard
  def paste
    read_from_clipboard do |text|
      target_set_value(:pasteOutput, text)
      console_styled("Pasted from clipboard", "color: blue;")
    end
  end

  # Action: Debounced search demo
  def search_debounced
    debounced(300, 'search') do
      @search_count += 1
      query = target_value(:searchInput)
      target_set_html(:searchOutput,
        "Searching for: <strong>#{query}</strong><br>" \
        "<small>Search triggered #{@search_count} time(s)</small>")
    end
  end

  # Action: Throttled action demo
  def throttled_action
    throttled(1000, 'click') do
      @throttle_count += 1
      console_time("Throttled action executed (#{@throttle_count})")
      show_toast("Throttled! Count: #{@throttle_count}")
    end
  end

  # Action: Unique array demo
  def unique_demo
    arr = [1, 2, 2, 3, 3, 3, 4, 5, 5]
    result = unique(arr)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Original:</strong> [#{arr.join(', ')}]</div>
        <div><strong>unique():</strong> [#{result.join(', ')}]</div>
      </div>
    HTML

    target_set_html(:setOutput, output)
  end

  # Action: Set operations demo
  def set_operations
    arr1_val = target_value(:arr1)
    arr2_val = target_value(:arr2)

    # Parse arrays
    arr1 = parse_array(arr1_val)
    arr2 = parse_array(arr2_val)

    union_result = union(arr1, arr2)
    intersection_result = intersection(arr1, arr2)
    difference_result = difference(arr1, arr2)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Array 1:</strong> [#{arr1.join(', ')}]</div>
        <div><strong>Array 2:</strong> [#{arr2.join(', ')}]</div>
        <hr class="my-2">
        <div><strong>union():</strong> [#{union_result.join(', ')}]</div>
        <div><strong>intersection():</strong> [#{intersection_result.join(', ')}]</div>
        <div><strong>difference():</strong> [#{difference_result.join(', ')}]</div>
      </div>
    HTML

    target_set_html(:setOutput, output)
  end

  # Action: Deep clone demo
  def deep_clone_demo
    original = { name: "John", nested: { city: "Tokyo", data: [1, 2, 3] } }
    cloned = deep_clone(original)

    # Modify cloned to show independence
    `#{cloned}.nested.city = "Osaka"`

    output = <<~HTML
      <div class="space-y-2">
        <div>
          <strong>Original:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{original.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>Cloned (modified):</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{cloned}, null, 2)`}</pre>
        </div>
        <div class="text-sm text-gray-600">
          Note: Original is unchanged even after modifying the clone
        </div>
      </div>
    HTML

    target_set_html(:objOutput, output)
  end

  # Action: Deep merge demo
  def deep_merge_demo
    target = { name: "John", address: { city: "Tokyo" }, tags: ["ruby"] }
    source = { age: 30, address: { zip: "100-0001" }, tags: ["javascript"] }
    merged = deep_merge(target, source)

    output = <<~HTML
      <div class="space-y-2">
        <div>
          <strong>Target:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{target.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>Source:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{source.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>deep_merge():</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{merged}, null, 2)`}</pre>
        </div>
      </div>
    HTML

    target_set_html(:objOutput, output)
  end

  # Action: Pick/omit demo
  def pick_omit_demo
    obj = { id: 1, name: "John", email: "john@example.com", password: "secret", role: "admin" }

    picked = pick(obj, :id, :name, :email)
    omitted = omit(obj, :password)

    output = <<~HTML
      <div class="space-y-2">
        <div>
          <strong>Original:</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{obj.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>pick(:id, :name, :email):</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{picked.to_n}, null, 2)`}</pre>
        </div>
        <div>
          <strong>omit(:password):</strong>
          <pre class="bg-gray-100 p-2 rounded text-sm">#{`JSON.stringify(#{omitted.to_n}, null, 2)`}</pre>
        </div>
      </div>
    HTML

    target_set_html(:objOutput, output)
  end

  # Action: Console helpers demo
  def console_demo
    console_styled("This is a styled message!", "color: purple; font-size: 16px;")

    console_group("Group Demo", collapsed: false) do
      puts "Message 1"
      puts "Message 2"
      console_table([
        { name: "Alice", age: 25 },
        { name: "Bob", age: 30 },
        { name: "Charlie", age: 35 }
      ])
    end

    console_time("This message has a timestamp")

    show_toast("Check the browser console!")
  end

  private

  def parse_array(str)
    return [] if blank?(str)
    str.split(',').map(&:strip).reject(&:empty?)
  end

  def show_toast(message)
    # Simple toast using DOM manipulation
    toast = `document.createElement('div')`
    `#{toast}.className = 'fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded shadow-lg z-50'`
    `#{toast}.textContent = #{message}`
    `document.body.appendChild(#{toast})`

    set_timeout(2000) do
      `#{toast}.remove()`
    end
  end
end
