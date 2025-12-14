# backtick_javascript: true

# Clipboard controller demonstrating DOM manipulation
class ClipboardController < StimulusController
  self.targets = ["source", "button"]
  self.classes = ["supported"]

  def connect
    if supported?
      element.class_list.add(*supported_classes)
    end
  end

  def copy
    # Select the text in the input field and copy using JavaScript directly
    `
      this.sourceTarget.select();

      const text = this.sourceTarget.value;
      navigator.clipboard.writeText(text).then(() => {
        console.log('Text copied to clipboard');
        this.buttonTarget.textContent = "Copied!";

        setTimeout(() => {
          this.buttonTarget.textContent = "Copy to Clipboard";
        }, 2000);
      }).catch((err) => {
        console.error('Failed to copy text: ', err);
      });
    `
  end

  private

  def supported?
    # Check if clipboard API is available
    `navigator.clipboard !== undefined`
  end
end
