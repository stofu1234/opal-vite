require 'react'

class Greeting
  include React::Component

  define_state :name, ''

  def render
    div class_name: 'greeting-container' do
      div class_name: 'greeting-card' do
        h2 'Greeting Component'

        div class_name: 'input-group' do
          label 'Enter your name:'
          input(
            type: 'text',
            value: state.name,
            on_change: method(:handle_change),
            placeholder: 'Your name here...',
            class_name: 'name-input'
          )
        end

        if state.name && !state.name.empty?
          div class_name: 'greeting-message' do
            h3 "Hello, #{state.name}! 👋"
            p "Welcome to Opal + React.rb + Vite!"
          end
        else
          div class_name: 'greeting-placeholder' do
            p 'Type your name to see a greeting'
          end
        end
      end
    end
  end

  def handle_change(event)
    set_state(name: event.target.value)
  end
end
