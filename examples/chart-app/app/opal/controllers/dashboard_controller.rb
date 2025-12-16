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
    fetch_and_process_data do |users|
      hide_loading
      process_user_data(users)
      update_stats(users)
      dispatch_window_event('show-toast', {
        message: 'Dashboard refreshed!',
        type: 'success'
      })
    end
  end

  private

  def fetch_data
    show_loading
    fetch_and_process_data do |users|
      hide_loading
      process_user_data(users)
      update_stats(users)
    end
  end

  def fetch_and_process_data(&on_complete)
    fetch_json('https://jsonplaceholder.typicode.com/users') do |users|
      on_complete.call(users) if on_complete
    end
  end

  def process_user_data(users)
    # Count users by company
    company_count = count_by(users) { |user| js_get(js_get(user, :company), :name) }

    dispatch_window_event('update-company-chart', {
      labels: js_keys(company_count),
      data: js_values(company_count)
    })

    # Count users by city
    city_count = count_by(users) { |user| js_get(js_get(user, :address), :city) }

    dispatch_window_event('update-city-chart', {
      labels: js_slice(js_keys(city_count), 0, 6),
      data: js_slice(js_values(city_count), 0, 6)
    })

    # Generate random activity data
    activity_data = (0...7).map { random_int(100) }
    dispatch_window_event('update-activity-chart', {
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      data: activity_data
    })
  end

  def count_by(arr, &key_block)
    result = js_object
    js_each(arr) do |item|
      key = key_block.call(item)
      current = js_get(result, key) || 0
      js_set(result, key, current + 1)
    end
    result
  end

  def update_stats(users)
    return unless has_target?(:stats)

    total_users = js_length(users)
    company_names = js_map(users) { |u| js_get(js_get(u, :company), :name) }
    total_companies = js_unique_count(company_names)
    city_names = js_map(users) { |u| js_get(js_get(u, :address), :city) }
    total_cities = js_unique_count(city_names)

    lat_sum = js_reduce(users, 0) do |sum, u|
      lat = js_get(js_get(js_get(u, :address), :geo), :lat)
      sum + parse_float(lat)
    end
    avg_latitude = js_to_fixed(lat_sum / total_users, 2)

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
