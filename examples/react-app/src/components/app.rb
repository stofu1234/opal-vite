require 'react'
require_relative 'counter'
require_relative 'greeting'
require_relative 'todo_list'

class App
  include React::Component

  def render
    div class_name: 'app' do
      div class_name: 'components-grid' do
        Counter()
        Greeting()
        TodoList()
      end

      footer class_name: 'app-footer' do
        p do
          text 'Built with '
          strong 'Ruby (Opal)'
          text ' + '
          strong 'React.rb'
          text ' + '
          strong 'Vite'
        end
        p class_name: 'footer-note' do
          text 'Check the browser console to see Ruby code running! 🚀'
        end
      end
    end
  end
end
