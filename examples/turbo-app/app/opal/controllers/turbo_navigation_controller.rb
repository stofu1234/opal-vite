# backtick_javascript: true

# Demonstrates Turbo Drive navigation from Ruby
class TurboNavigationController < StimulusController
  def connect
    puts "TurboNavigation controller connected!"
  end

  def visit_page
    # Get the target page from the clicked button and navigate using Turbo
    # Note: 'event' is available globally in the JavaScript context
    `
      const button = event.currentTarget;
      const page = button.getAttribute('data-page');
      console.log('Navigating to:', page);
      window.Turbo.visit(page);
    `
  end

  def visit_with_replace
    # Navigate with replace action (replaces current history entry)
    `
      const button = event.currentTarget;
      const page = button.getAttribute('data-page');
      console.log('Navigating to', page, 'with replace action');
      window.Turbo.visit(page, { action: 'replace' });
    `
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
