# Chart App - Data Visualization Example

An interactive data visualization dashboard demonstrating Chart.js integration with Opal, Stimulus, and Vite. This example shows how to create dynamic, real-time charts and dashboards using modern web technologies.

## Features

- **Multiple Chart Types**: Pie, doughnut, bar, and line charts
- **Real-time Data**: Fetches and displays data from JSONPlaceholder API
- **Interactive Controls**: Add, remove, and randomize chart data
- **Event-Driven Updates**: Charts listen for custom events and update automatically
- **Responsive Design**: Adapts to different screen sizes
- **Modern Dashboard UI**: Professional-looking data visualization interface

## Chart Types

### Static Data Charts (API-driven)
1. **Pie Chart**: Users by company distribution
2. **Doughnut Chart**: Users by city distribution
3. **Bar Chart**: Weekly activity simulation

### Interactive Chart
4. **Line Chart**: Manual data manipulation with controls
   - Randomize data points
   - Add new data points
   - Remove last data point

## Getting Started

### Prerequisites

- Ruby 3.0 or higher
- Node.js 18 or higher
- pnpm (or npm/yarn)

### Installation

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
pnpm install
```

### Running the App

```bash
# Start the development server
pnpm dev
```

The app will be available at http://localhost:3008/

## Project Structure

```
chart-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # JavaScript entry point (Chart.js import)
│   ├── opal/
│   │   ├── application.rb           # Ruby entry point
│   │   └── controllers/
│   │       ├── chart_controller.rb        # Base chart controller
│   │       ├── data_chart_controller.rb   # Event-driven chart controller
│   │       └── dashboard_controller.rb    # Dashboard & data fetching
│   └── styles.css                  # Dashboard styles
├── index.html                      # Main HTML template
├── vite.config.ts                  # Vite configuration
├── package.json                    # Node.js dependencies
└── Gemfile                         # Ruby dependencies
```

## Controller Architecture

### ChartController

The base chart controller manages Chart.js instances and provides methods for data manipulation.

**Targets:**
- `canvas` - Canvas element for rendering charts

**Values:**
- `type` - Chart type (line, bar, pie, doughnut)
- `data` - JSON string with chart data
- `options` - JSON string with chart options

**Key Methods:**

#### `connect`
Initializes the Chart.js instance with specified type and data:

```ruby
def connect
  `
    const chartType = this.typeValue || 'line';
    const chartData = this.getDefaultData(chartType);
    const chartOptions = this.getDefaultOptions(chartType);

    this.chart = new Chart(ctx, {
      type: chartType,
      data: chartData,
      options: chartOptions
    });
  `
end
```

#### `update_chart`
Randomizes the chart data:

```ruby
def update_chart
  `
    if (this.chart) {
      this.randomizeData();
    }
  `
end
```

#### `add_data` / `remove_data`
Add or remove data points from the chart:

```ruby
def add_data
  `
    const newLabel = monthNames[currentLabels % 12];
    const newValues = [Math.random() * 30, Math.random() * 30];
    this.addDataPoint(newLabel, newValues);
  `
end
```

### DataChartController

Extends `ChartController` to listen for custom events and update charts with external data.

**Additional Values:**
- `event_name` - Name of the custom event to listen for

**Key Features:**

```ruby
def connect
  super  # Initialize base chart

  `
    const eventName = this.eventNameValue || 'update-chart';

    window.addEventListener(eventName, (e) => {
      const { labels, data } = e.detail;

      // Update chart data
      this.chart.data.labels = labels;
      this.chart.data.datasets[0].data = data;
      this.chart.update('active');
    });
  `
end
```

### DashboardController

Manages data fetching from APIs and dispatches events to update charts.

**Targets:**
- `stats` - Statistics cards container
- `loading` - Loading overlay

**Key Methods:**

#### `connect`
Fetches data from JSONPlaceholder API and processes it:

```ruby
def connect
  `
    fetch('https://jsonplaceholder.typicode.com/users')
      .then(response => response.json())
      .then(users => {
        this.processUserData(users);
        this.updateStats(users);
      });
  `
end
```

#### `processUserData`
Transforms API data and dispatches custom events for charts:

```ruby
this.processUserData = function(users) {
  // Count users by company
  const companyCount = {};
  users.forEach(user => {
    const company = user.company.name;
    companyCount[company] = (companyCount[company] || 0) + 1;
  });

  // Dispatch event for company chart
  const chartEvent = new CustomEvent('update-company-chart', {
    detail: {
      labels: Object.keys(companyCount),
      data: Object.values(companyCount)
    }
  });
  window.dispatchEvent(chartEvent);
};
```

## Technical Concepts

### Chart.js Integration

Chart.js is imported in the JavaScript entry point and made available globally:

```javascript
import Chart from 'chart.js/auto'
window.Chart = Chart
```

This allows Opal/Ruby code to access Chart.js through backtick JavaScript:

```ruby
`
  this.chart = new Chart(ctx, {
    type: 'line',
    data: chartData,
    options: chartOptions
  });
`
```

### Event-Driven Architecture

Charts are updated using custom events for loose coupling:

**Dispatching Events:**
```javascript
const event = new CustomEvent('update-company-chart', {
  detail: { labels: [...], data: [...] }
});
window.dispatchEvent(event);
```

**Listening for Events:**
```javascript
window.addEventListener('update-company-chart', (e) => {
  const { labels, data } = e.detail;
  this.chart.data.labels = labels;
  this.chart.data.datasets[0].data = data;
  this.chart.update();
});
```

### Chart.js Configuration

Each chart type has different data structures:

**Line/Bar Charts:**
```javascript
{
  labels: ['Jan', 'Feb', 'Mar'],
  datasets: [{
    label: 'Dataset 1',
    data: [12, 19, 3],
    backgroundColor: 'rgba(102, 126, 234, 0.5)'
  }]
}
```

**Pie/Doughnut Charts:**
```javascript
{
  labels: ['Red', 'Blue', 'Yellow'],
  datasets: [{
    data: [300, 50, 100],
    backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56']
  }]
}
```

### Dynamic Data Updates

Chart.js provides the `update()` method for smooth transitions:

```javascript
// Update data
chart.data.datasets[0].data = [newData];
chart.update();  // Animates the transition

// For immediate update without animation
chart.update('none');

// For active elements animation
chart.update('active');
```

## Common Patterns

### 1. Creating a New Chart

```ruby
def connect
  `
    const ctx = this.canvasTarget.getContext('2d');

    this.chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['A', 'B', 'C'],
        datasets: [{
          label: 'My Dataset',
          data: [10, 20, 30]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    });
  `
end
```

### 2. Updating Existing Chart

```ruby
def update_data
  `
    this.chart.data.datasets[0].data = [15, 25, 35];
    this.chart.update();
  `
end
```

### 3. Destroying Charts

Always destroy charts when the controller disconnects:

```ruby
def disconnect
  `
    if (this.chart) {
      this.chart.destroy();
    }
  `
end
```

### 4. Fetching and Processing API Data

```ruby
`
  fetch(url)
    .then(response => response.json())
    .then(data => {
      // Process data
      const labels = data.map(item => item.name);
      const values = data.map(item => item.value);

      // Dispatch event
      const event = new CustomEvent('update-chart', {
        detail: { labels, values }
      });
      window.dispatchEvent(event);
    });
`
```

## Extending the App

Ideas for extending this dashboard:

1. **More Chart Types**: Add polar area, radar, or scatter charts
2. **Real-time Updates**: Use WebSocket for live data streaming
3. **Data Export**: Export charts as PNG/PDF
4. **Custom Themes**: Add dark mode or color scheme switcher
5. **Filters**: Add date range or category filters
6. **Drill-down**: Click chart segments for detailed views
7. **Multiple APIs**: Integrate with weather, stocks, or other APIs
8. **Animations**: Customize chart animation easing and duration
9. **Tooltips**: Add custom tooltip formatters
10. **Legends**: Implement custom legend handlers

## Troubleshooting

### Chart Not Rendering

If the chart doesn't appear:

1. Check browser console for JavaScript errors
2. Verify Chart.js is loaded: `console.log(window.Chart)`
3. Ensure canvas element exists: Check `data-chart-target="canvas"` in HTML
4. Verify controller is connected: Check "Chart controller connected!" in console

### Data Not Updating

If charts don't update with new data:

1. Check event name matches between dispatcher and listener
2. Verify data format matches chart type requirements
3. Check browser console for event dispatching
4. Ensure `chart.update()` is called after data changes

### API Data Not Loading

If API data doesn't load:

1. Check network tab for failed requests
2. Verify API endpoint is accessible
3. Check CORS settings if using different domain
4. Look for JSON parsing errors in console

## Chart.js Resources

- [Chart.js Documentation](https://www.chartjs.org/docs/latest/)
- [Chart Types](https://www.chartjs.org/docs/latest/charts/line.html)
- [Configuration Options](https://www.chartjs.org/docs/latest/configuration/)
- [Updating Charts](https://www.chartjs.org/docs/latest/developers/updates.html)
- [Responsive Charts](https://www.chartjs.org/docs/latest/configuration/responsive.html)

## Performance Considerations

- **Chart Destruction**: Always destroy charts in `disconnect()` to prevent memory leaks
- **Update Frequency**: Limit update frequency for real-time data (use debouncing/throttling)
- **Data Size**: Large datasets may impact performance - consider data aggregation
- **Animation**: Disable animations for frequent updates: `chart.update('none')`
- **Canvas Size**: Maintain aspect ratio or set explicit dimensions for better performance

## Additional Resources

- [Opal Documentation](https://opalrb.com/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Vite Guide](https://vitejs.dev/guide/)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)
