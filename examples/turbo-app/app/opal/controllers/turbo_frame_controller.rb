# backtick_javascript: true

# Demonstrates Turbo Frames manipulation from Ruby
class TurboFrameController < StimulusController
  include StimulusHelpers

  self.targets = ["frame", "content"]

  def connect
    puts "TurboFrame controller connected!"
  end

  def load_content
    frame_id = event_data('frame-id')
    url = event_data('url')
    puts "Loading content into frame: #{frame_id} from #{url}"

    frame = query("##{frame_id}")
    `#{frame}.src = #{url}` if frame
  end

  def update_frame_content
    frame_id = event_data('frame-id')
    timestamp = `new Date().toLocaleTimeString()`

    puts "Updating frame #{frame_id} with new content"

    content = <<~HTML
      <div class="demo-box">
        <h4>Updated!</h4>
        <p>Frame content was updated from Ruby at #{timestamp}</p>
      </div>
    HTML

    frame = query("##{frame_id}")
    set_html(frame, content) if frame
  end

  def toggle_loading
    puts "Toggling frame loading state"

    frame = query('#dynamic-frame')
    return unless frame

    if `#{frame}.hasAttribute('busy')`
      remove_attr(frame, 'busy')
      set_html(frame, '<div class="demo-box"><h4>Frame Content</h4><p>Content loaded!</p></div>')
    else
      set_attr(frame, 'busy', '')
      set_html(frame, '<div class="demo-box"><h4>Loading...</h4><p>Please wait...</p></div>')
    end
  end
end
