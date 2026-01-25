# backtick_javascript: true
# Opal application entry point
# This file is compiled to JavaScript and loaded in your Rails views

require 'native'

puts "🚀 Opal application loaded!"
puts "RUBY_VERSION: #{RUBY_VERSION}"
puts "RUBY_PLATFORM: #{RUBY_PLATFORM}"

# Example: DOM manipulation using Native wrapper
doc = Native($$.document)
console = Native($$.console)

# Wait for DOM to load
doc.addEventListener('DOMContentLoaded') do
  console.log('✅ Opal is running in Rails!')

  # Example: Add content to the page
  content = doc.getElementById('opal-content')
  if content
    p_el = doc.createElement('p')
    p_el.textContent = 'This content was added by Ruby code running in the browser!'
    p_el.style.color = '#CC342D'
    p_el.style.fontWeight = 'bold'
    content.appendChild(p_el)
  end
end

puts "✅ Opal application initialized"
