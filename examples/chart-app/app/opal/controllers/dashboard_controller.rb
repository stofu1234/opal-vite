# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

# Dashboard controller for managing multiple charts
class DashboardController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers

  self.targets = %w[stats loading]

  API_URL = 'https://jsonplaceholder.typicode.com/users'.freeze
  WEEKDAYS = %w[Mon Tue Wed Thu Fri Sat Sun].freeze

  def connect
    puts 'Dashboard controller connected!'
    fetch_data
  end

  # Stimulus action: Refresh dashboard data
  def refresh
    show_loading
    fetch_data(show_toast: true)
  end

  private

  def fetch_data(show_toast: false)
    show_loading

    `
      const ctrl = this;
      fetch(#{API_URL})
        .then(function(response) { return response.json(); })
        .then(function(users) {
          ctrl.$hide_loading();
          ctrl.$process_users(users);
          if (#{show_toast}) {
            ctrl.$show_success('Dashboard refreshed!');
          }
        })
        .catch(function(error) {
          console.error('Error fetching data:', error);
          ctrl.$hide_loading();
          if (#{show_toast}) {
            ctrl.$show_error('Failed to refresh dashboard');
          }
        });
    `
  end

  def process_users(js_users)
    users = convert_users_to_ruby(js_users)

    update_company_chart(users)
    update_city_chart(users)
    update_activity_chart
    update_stats(users)
  end

  def convert_users_to_ruby(js_users)
    users = []
    length = `#{js_users}.length`
    length.times do |i|
      user = `#{js_users}[#{i}]`
      users << {
        name: `#{user}.name`,
        company: `#{user}.company.name`,
        city: `#{user}.address.city`,
        lat: `parseFloat(#{user}.address.geo.lat)`
      }
    end
    users
  end

  def update_company_chart(users)
    company_count = {}
    users.each do |user|
      company = user[:company]
      company_count[company] ||= 0
      company_count[company] += 1
    end

    dispatch_custom_event('update-company-chart', {
      labels: company_count.keys,
      data: company_count.values
    })
  end

  def update_city_chart(users)
    city_count = {}
    users.each do |user|
      city = user[:city]
      city_count[city] ||= 0
      city_count[city] += 1
    end

    labels = city_count.keys.first(6)
    data = city_count.values.first(6)

    dispatch_custom_event('update-city-chart', {
      labels: labels,
      data: data
    })
  end

  def update_activity_chart
    activity_data = 7.times.map { random_activity }

    dispatch_custom_event('update-activity-chart', {
      labels: WEEKDAYS,
      data: activity_data
    })
  end

  def update_stats(users)
    return unless `this.hasStatsTarget`

    total_users = users.length
    total_companies = users.map { |u| u[:company] }.uniq.length
    total_cities = users.map { |u| u[:city] }.uniq.length
    avg_latitude = (users.sum { |u| u[:lat] } / users.length).round(2)

    html = build_stats_html(total_users, total_companies, total_cities, avg_latitude)
    `this.statsTarget.innerHTML = #{html}`
  end

  def build_stats_html(total_users, total_companies, total_cities, avg_latitude)
    "<div class=\"stat-card\">" \
      "<div class=\"stat-value\">#{total_users}</div>" \
      "<div class=\"stat-label\">Total Users</div>" \
    "</div>" \
    "<div class=\"stat-card\">" \
      "<div class=\"stat-value\">#{total_companies}</div>" \
      "<div class=\"stat-label\">Companies</div>" \
    "</div>" \
    "<div class=\"stat-card\">" \
      "<div class=\"stat-value\">#{total_cities}</div>" \
      "<div class=\"stat-label\">Cities</div>" \
    "</div>" \
    "<div class=\"stat-card\">" \
      "<div class=\"stat-value\">#{avg_latitude}&deg;</div>" \
      "<div class=\"stat-label\">Avg Latitude</div>" \
    "</div>"
  end

  def show_loading
    `
      if (this.hasLoadingTarget) {
        this.loadingTarget.style.display = 'flex';
      }
    `
  end

  def hide_loading
    `
      if (this.hasLoadingTarget) {
        this.loadingTarget.style.display = 'none';
      }
    `
  end

  def random_activity
    `Math.floor(Math.random() * 100)`
  end
end
