# backtick_javascript: true
# HMR Test File - Edit this file and see changes instantly!

puts "🔥 HMR Test Module Loaded"
puts "Current time: #{Time.now}"

class HMRCounter
  @@count = 0

  def self.increment
    @@count += 1
    puts "Counter incremented to: #{@@count}"
    update_display
    @@count
  end

  def self.reset
    @@count = 0
    puts "Counter reset"
    update_display
  end

  def self.current
    @@count
  end

  def self.update_display
    `
      const display = document.getElementById('counter-display');
      if (display) {
        display.textContent = #{@@count};
      }
    `
  end
end

class MessageDisplay
  # Change this message and save to see HMR in action!
  MESSAGE = "Hello from Opal! 👋"

  # Change this color and save!
  COLOR = "#CC342D"

  def self.show
    puts "Displaying message: #{MESSAGE}"
    `
      const msg = document.getElementById('hmr-message');
      if (msg) {
        msg.textContent = #{MESSAGE};
        msg.style.color = #{COLOR};
      }
    `
  end
end

# Setup event handlers
`
  document.addEventListener('DOMContentLoaded', function() {
    console.log('🔥 HMR Test initialized');

    // Update initial display
    #{MessageDisplay.show}
    #{HMRCounter.update_display}

    // Increment button
    const incBtn = document.getElementById('hmr-increment');
    if (incBtn) {
      incBtn.addEventListener('click', function() {
        #{HMRCounter.increment}
      });
    }

    // Reset button
    const resetBtn = document.getElementById('hmr-reset');
    if (resetBtn) {
      resetBtn.addEventListener('click', function() {
        #{HMRCounter.reset}
      });
    }
  });

  // HMR Accept
  if (import.meta.hot) {
    import.meta.hot.accept((newModule) => {
      console.log('🔥 HMR: Module updated, re-rendering...');
      // Re-execute initialization
      #{MessageDisplay.show}
      #{HMRCounter.update_display}
    });
  }
`

puts "✅ HMR handlers registered"
puts "Edit this file (line 28-32) to see HMR in action!"
