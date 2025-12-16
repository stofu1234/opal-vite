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
    `#{source}.select()`

    text = get_value(source)

    # Copy using Clipboard API
    `
      const btn = #{button};
      navigator.clipboard.writeText(#{text}).then(() => {
        console.log('Text copied to clipboard');
        btn.textContent = "Copied!";
        setTimeout(() => {
          btn.textContent = "Copy to Clipboard";
        }, 2000);
      }).catch((err) => {
        console.error('Failed to copy text: ', err);
      });
    `
  end

  private

  def supported?
    `navigator.clipboard !== undefined`
  end
end
