# backtick_javascript: true

# Dashboard controller for managing multiple charts
class DashboardController < StimulusController
  include StimulusHelpers

  self.targets = ["stats", "loading"]

  def connect
    puts "Dashboard controller connected!"
    fetch_data
  end

  # Refresh dashboard data
  def refresh
    show_loading
    fetch_and_process_data do
      hide_loading
      dispatch_window_event('show-toast', {
        message: 'Dashboard refreshed!',
        type: 'success'
      })
    end
  end

  private

  def fetch_data
    show_loading
    fetch_and_process_data { hide_loading }
  end

  def fetch_and_process_data(&on_complete)
    `
      const ctrl = this;

      fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => response.json())
        .then(users => {
          #{on_complete.call if on_complete}
          ctrl.$process_user_data(users);
          ctrl.$update_stats(users);
        })
        .catch(error => {
          console.error('Error fetching data:', error);
          #{on_complete.call if on_complete}
        });
    `
  end

  def process_user_data(users)
    # Count users by company
    `
      const companyCount = {};
      #{users}.forEach(user => {
        const company = user.company.name;
        companyCount[company] = (companyCount[company] || 0) + 1;
      });
    `

    dispatch_window_event('update-company-chart', {
      labels: `Object.keys(companyCount)`,
      data: `Object.values(companyCount)`
    })

    # Count users by city
    `
      const cityCount = {};
      #{users}.forEach(user => {
        const city = user.address.city;
        cityCount[city] = (cityCount[city] || 0) + 1;
      });
    `

    dispatch_window_event('update-city-chart', {
      labels: `Object.keys(cityCount).slice(0, 6)`,
      data: `Object.values(cityCount).slice(0, 6)`
    })

    # Generate random activity data
    dispatch_window_event('update-activity-chart', {
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      data: `Array.from({ length: 7 }, () => Math.floor(Math.random() * 100))`
    })
  end

  def update_stats(users)
    return unless has_target?(:stats)

    total_users = `#{users}.length`
    total_companies = `new Set(#{users}.map(u => u.company.name)).size`
    total_cities = `new Set(#{users}.map(u => u.address.city)).size`
    avg_latitude = `(#{users}.reduce((sum, u) => sum + parseFloat(u.address.geo.lat), 0) / #{users}.length).toFixed(2)`

    html = <<~HTML
      <div class="stat-card">
        <div class="stat-value">#{total_users}</div>
        <div class="stat-label">Total Users</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">#{total_companies}</div>
        <div class="stat-label">Companies</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">#{total_cities}</div>
        <div class="stat-label">Cities</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">#{avg_latitude}°</div>
        <div class="stat-label">Avg Latitude</div>
      </div>
    HTML

    target_set_html(:stats, html)
  end

  def show_loading
    set_target_style(:loading, 'display', 'flex') if has_target?(:loading)
  end

  def hide_loading
    hide_target(:loading) if has_target?(:loading)
  end
end
