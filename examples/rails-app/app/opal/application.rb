# Opal application entry point
# This file is compiled to JavaScript and loaded in your Rails views

puts "🚀 Opal application loaded!"
puts "RUBY_VERSION: #{RUBY_VERSION}"
puts "RUBY_PLATFORM: #{RUBY_PLATFORM}"

# Example: DOM manipulation
require 'native'

# Wait for DOM to load
`
  document.addEventListener('DOMContentLoaded', function() {
    console.log('✅ Opal is running in Rails!');

    // Example: Add content to the page
    const content = document.getElementById('opal-content');
    if (content) {
      const p = document.createElement('p');
      p.textContent = 'This content was added by Ruby code running in the browser!';
      p.style.color = '#CC342D';
      p.style.fontWeight = 'bold';
      content.appendChild(p);
    }
  });
`

puts "✅ Opal application initialized"
