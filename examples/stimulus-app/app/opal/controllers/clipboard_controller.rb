# backtick_javascript: true

# Clipboard controller demonstrating DOM manipulation
class ClipboardController < StimulusController
  include JsProxyEx

  self.targets = ["source", "button"]
  self.classes = ["supported"]

  def connect
    if supported?
      element.class_list.add(*supported_classes)
    end
  end

  def copy
    `
      const ctrl = this;
      if (!this.hasSourceTarget || !this.hasButtonTarget) return;

      this.sourceTarget.select();
      const text = this.sourceTarget.value;

      navigator.clipboard.writeText(text).then(function() {
        console.log('Text copied to clipboard');
        ctrl.buttonTarget.textContent = "Copied!";

        setTimeout(function() {
          ctrl.buttonTarget.textContent = "Copy to Clipboard";
        }, 2000);
      }).catch(function(err) {
        console.log('Failed to copy text:', err);
      });
    `
  end

  private

  def supported?
    `navigator.clipboard !== undefined`
  end
end
