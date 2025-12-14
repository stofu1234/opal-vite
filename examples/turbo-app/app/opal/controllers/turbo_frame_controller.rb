# backtick_javascript: true

# Demonstrates Turbo Frames manipulation from Ruby
class TurboFrameController < StimulusController
  self.targets = ["frame", "content"]

  def connect
    puts "TurboFrame controller connected!"
  end

  def load_content
    # Find the turbo-frame element and set its src
    # Note: 'event' is available globally in the JavaScript context
    `
      const button = event.currentTarget;
      const frameId = button.getAttribute('data-frame-id');
      const url = button.getAttribute('data-url');
      console.log('Loading content into frame:', frameId, 'from', url);

      const frame = document.getElementById(frameId);
      if (frame) {
        frame.src = url;
      }
    `
  end

  def update_frame_content
    # Directly update frame content with current timestamp
    `
      const button = event.currentTarget;
      const frameId = button.getAttribute('data-frame-id');
      const timestamp = new Date().toLocaleTimeString();
      const content = '<div class="demo-box"><h4>Updated!</h4><p>Frame content was updated from Ruby at ' + timestamp + '</p></div>';

      console.log('Updating frame', frameId, 'with new content');

      const frame = document.getElementById(frameId);
      if (frame) {
        frame.innerHTML = content;
      }
    `
  end

  def toggle_loading
    # Simulate loading state
    puts "Toggling frame loading state"

    `
      const frame = document.getElementById('dynamic-frame');
      if (frame) {
        if (frame.hasAttribute('busy')) {
          frame.removeAttribute('busy');
          frame.innerHTML = '<div class="demo-box"><h4>Frame Content</h4><p>Content loaded!</p></div>';
        } else {
          frame.setAttribute('busy', '');
          frame.innerHTML = '<div class="demo-box"><h4>Loading...</h4><p>Please wait...</p></div>';
        }
      }
    `
  end
end
