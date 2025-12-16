# backtick_javascript: true

# Demonstrates Turbo Drive navigation from Ruby
class TurboNavigationController < StimulusController
  include StimulusHelpers

  def connect
    puts "TurboNavigation controller connected!"
  end

  def visit_page
    page = event_data('page')
    puts "Navigating to: #{page}"
    `window.Turbo.visit(#{page})`
  end

  def visit_with_replace
    page = event_data('page')
    puts "Navigating to #{page} with replace action"
    `window.Turbo.visit(#{page}, { action: 'replace' })`
  end

  def go_back
    puts "Going back in history"
    `window.history.back()`
  end

  def reload_page
    puts "Reloading current page"
    `window.location.reload()`
  end
end
