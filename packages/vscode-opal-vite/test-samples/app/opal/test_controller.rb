# Test file for Opal Vite VS Code Extension
# This file demonstrates various Opal patterns and incompatible code

require 'opal_stimulus'
require 'opal_vite'

class TestController < StimulusController
  include OpalVite::Concerns::V1::DomHelpers
  include OpalVite::Concerns::V1::Storable

  def connect
    puts "Controller connected!"

    # Native JavaScript block (should be highlighted)
    `console.log("Hello from JavaScript!")`

    # OpalVite helper methods
    element = query_selector('.my-element')
    local_storage_set('key', 'value')
  end

  def fetch_data
    # This is OK - using PromiseV2
    PromiseV2.new do |resolve, reject|
      resolve.call({ data: 'test' })
    end
  end
end

# ============================================
# INCOMPATIBLE CODE BELOW - Should show warnings/errors
# ============================================

# Threading - NOT supported (should show ERROR)
Thread.new { puts "This won't work" }
Mutex.new

# File system - NOT supported (should show ERROR)
File.read('somefile.txt')
Dir.glob('*.rb')

# Sockets - NOT supported (should show ERROR)
TCPSocket.new('localhost', 80)

# System commands - NOT supported (should show ERROR)
system('ls -la')

# Native C extension gems - NOT supported (should show ERROR)
require 'nokogiri'
require 'mysql2'

# ============================================
# HINTS - Should show helpful tips
# ============================================

# JSON hint
require 'json'

# Time hint
current_time = Time.now

# Random hint
random_num = Random.rand(100)
