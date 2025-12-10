# backtick_javascript: true
# Simple test to verify Opal is working

puts "=== Opal Simple Test ==="
puts "Ruby is running in the browser!"
puts "RUBY_VERSION: #{RUBY_VERSION}"
puts "RUBY_PLATFORM: #{RUBY_PLATFORM}"

# Test basic Ruby
result = [1, 2, 3, 4, 5].map { |n| n * 2 }
puts "Array map test: #{result.inspect}"

# Test DOM interaction
`
  console.log('✅ JavaScript backticks working!');

  document.addEventListener('DOMContentLoaded', function() {
    console.log('✅ DOMContentLoaded fired');

    const testBtn = document.getElementById('test-button');
    console.log('Button element:', testBtn);

    if (testBtn) {
      testBtn.addEventListener('click', function() {
        console.log('✅ Button clicked!');
        alert('Button works! Ruby is running.');
      });
      console.log('✅ Event listener attached');
    } else {
      console.error('❌ Button element not found!');
    }
  });
`

puts "=== Initialization complete ==="
