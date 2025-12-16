# backtick_javascript: true

# Clipboard controller demonstrating DOM manipulation
class ClipboardController < StimulusController
  include StimulusHelpers

  self.targets = ["source", "button"]
  self.classes = ["supported"]

  def connect
    if supported?
      element.class_list.add(*supported_classes)
    end
  end

  def copy
    source = get_target(:source)
    button = get_target(:button)

    # Select the text
    js_call_on(source, :select)

    text = get_value(source)

    # Copy using Clipboard API
    clipboard = js_get(js_global('navigator'), :clipboard)
    promise = js_call_on(clipboard, :writeText, text)

    js_then(promise) do
      console_log('Text copied to clipboard')
      set_text(button, 'Copied!')
      set_timeout(2000) do
        set_text(button, 'Copy to Clipboard')
      end
    end

    js_catch(promise) do |err|
      console_error('Failed to copy text: ', err)
    end
  end

  private

  def supported?
    clipboard = js_get(js_global('navigator'), :clipboard)
    `#{clipboard} !== undefined`
  end
end
