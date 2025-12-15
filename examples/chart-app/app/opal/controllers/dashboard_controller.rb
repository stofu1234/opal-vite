# backtick_javascript: true

# Dashboard controller for managing multiple charts
class DashboardController < StimulusController
  self.targets = ["stats", "loading"]

  def connect
    puts "Dashboard controller connected!"

    # Fetch data from API
    `
      const ctrl = this;

      // Process user data for charts
      ctrl.processUserData = function(users) {
        // Count users by company
        const companyCount = {};
        users.forEach(user => {
          const company = user.company.name;
          companyCount[company] = (companyCount[company] || 0) + 1;
        });

        // Dispatch custom event with chart data
        const chartEvent = new CustomEvent('update-company-chart', {
          detail: {
            labels: Object.keys(companyCount),
            data: Object.values(companyCount)
          }
        });
        window.dispatchEvent(chartEvent);

        // Count users by city
        const cityCount = {};
        users.forEach(user => {
          const city = user.address.city;
          cityCount[city] = (cityCount[city] || 0) + 1;
        });

        // Dispatch event for city chart
        const cityEvent = new CustomEvent('update-city-chart', {
          detail: {
            labels: Object.keys(cityCount).slice(0, 6),
            data: Object.values(cityCount).slice(0, 6)
          }
        });
        window.dispatchEvent(cityEvent);

        // Generate random activity data
        const activityData = Array.from({ length: 7 }, () => Math.floor(Math.random() * 100));
        const activityEvent = new CustomEvent('update-activity-chart', {
          detail: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            data: activityData
          }
        });
        window.dispatchEvent(activityEvent);
      };

      // Update statistics
      ctrl.updateStats = function(users) {
        const totalUsers = users.length;
        const totalCompanies = new Set(users.map(u => u.company.name)).size;
        const totalCities = new Set(users.map(u => u.address.city)).size;
        const avgLatitude = (users.reduce((sum, u) => sum + parseFloat(u.address.geo.lat), 0) / users.length).toFixed(2);

        ctrl.statsTarget.innerHTML = '<div class="stat-card">' +
          '<div class="stat-value">' + totalUsers + '</div>' +
          '<div class="stat-label">Total Users</div>' +
        '</div>' +
        '<div class="stat-card">' +
          '<div class="stat-value">' + totalCompanies + '</div>' +
          '<div class="stat-label">Companies</div>' +
        '</div>' +
        '<div class="stat-card">' +
          '<div class="stat-value">' + totalCities + '</div>' +
          '<div class="stat-label">Cities</div>' +
        '</div>' +
        '<div class="stat-card">' +
          '<div class="stat-value">' + avgLatitude + '°</div>' +
          '<div class="stat-label">Avg Latitude</div>' +
        '</div>';
      };

      // Now fetch data after helper functions are defined
      // Show loading
      if (ctrl.hasLoadingTarget) {
        ctrl.loadingTarget.style.display = 'flex';
      }

      // Fetch user data from JSONPlaceholder API
      fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => response.json())
        .then(users => {
          // Hide loading
          if (ctrl.hasLoadingTarget) {
            ctrl.loadingTarget.style.display = 'none';
          }

          // Process user data
          ctrl.processUserData(users);

          // Update stats
          if (ctrl.hasStatsTarget) {
            ctrl.updateStats(users);
          }
        })
        .catch(error => {
          console.error('Error fetching data:', error);

          // Hide loading
          if (ctrl.hasLoadingTarget) {
            ctrl.loadingTarget.style.display = 'none';
          }
        });
    `
  end

  # Refresh dashboard data
  def refresh
    `
      // Show loading
      if (this.hasLoadingTarget) {
        this.loadingTarget.style.display = 'flex';
      }

      // Re-fetch data
      fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => response.json())
        .then(users => {
          // Hide loading
          if (this.hasLoadingTarget) {
            this.loadingTarget.style.display = 'none';
          }

          this.processUserData(users);
          this.updateStats(users);

          // Show success toast (if available)
          const toastEvent = new CustomEvent('show-toast', {
            detail: {
              message: 'Dashboard refreshed!',
              type: 'success'
            }
          });
          window.dispatchEvent(toastEvent);
        })
        .catch(error => {
          console.error('Error refreshing data:', error);

          if (this.hasLoadingTarget) {
            this.loadingTarget.style.display = 'none';
          }
        });
    `
  end
end
