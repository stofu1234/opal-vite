# backtick_javascript: true

# Chart controller demonstrating Chart.js integration
class ChartController < StimulusController
  include StimulusHelpers

  self.targets = ["canvas"]
  self.values = { type: :string, data: :string, options: :string, event_name: :string }

  def connect
    puts "Chart controller connected!"
    initialize_chart
  end

  def disconnect
    `
      if (this.chart) {
        this.chart.destroy();
      }
    `
  end

  # Update chart with new data
  def update_chart
    `
      if (this.chart) {
        this.randomizeData();
      }
    `
  end

  # Add new data point
  def add_data
    `
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const currentLabels = this.chart.data.labels.length;
      const newLabel = monthNames[currentLabels % 12];
      const newValues = [Math.floor(Math.random() * 30), Math.floor(Math.random() * 30)];
      this.addDataPoint(newLabel, newValues);
    `
  end

  # Remove last data point
  def remove_data
    `this.removeDataPoint()`
  end

  private

  def initialize_chart
    # Chart.js initialization requires pure JavaScript due to complex object structures
    `
      const ctrl = this;

      if (typeof Chart === 'undefined') {
        console.error('Chart.js is not loaded!');
        return;
      }

      // Helper functions
      ctrl.getDefaultData = function(type) {
        const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
        const data1 = [12, 19, 3, 5, 2, 3];
        const data2 = [2, 3, 20, 5, 1, 4];
        const colors = [
          'rgba(102, 126, 234, 0.8)',
          'rgba(118, 75, 162, 0.8)',
          'rgba(237, 100, 166, 0.8)',
          'rgba(255, 159, 64, 0.8)',
          'rgba(75, 192, 192, 0.8)',
          'rgba(153, 102, 255, 0.8)'
        ];

        if (type === 'pie' || type === 'doughnut') {
          return { labels, datasets: [{ data: data1, backgroundColor: colors }] };
        }
        return {
          labels,
          datasets: [
            { label: 'Dataset 1', data: data1, backgroundColor: 'rgba(102, 126, 234, 0.5)', borderColor: 'rgba(102, 126, 234, 1)', borderWidth: 2 },
            { label: 'Dataset 2', data: data2, backgroundColor: 'rgba(118, 75, 162, 0.5)', borderColor: 'rgba(118, 75, 162, 1)', borderWidth: 2 }
          ]
        };
      };

      ctrl.getDefaultOptions = function() {
        return {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: true, position: 'top' }, title: { display: false } }
        };
      };

      ctrl.addDataPoint = function(label, values) {
        if (!ctrl.chart) return;
        ctrl.chart.data.labels.push(label);
        ctrl.chart.data.datasets.forEach((dataset, i) => {
          dataset.data.push(Array.isArray(values) ? values[i] : values);
        });
        ctrl.chart.update();
      };

      ctrl.removeDataPoint = function() {
        if (!ctrl.chart) return;
        ctrl.chart.data.labels.pop();
        ctrl.chart.data.datasets.forEach(d => d.data.pop());
        ctrl.chart.update();
      };

      ctrl.randomizeData = function() {
        if (!ctrl.chart) return;
        ctrl.chart.data.datasets.forEach(d => {
          d.data = d.data.map(() => Math.floor(Math.random() * 30));
        });
        ctrl.chart.update();
      };

      // Initialize chart
      const chartType = ctrl.typeValue || 'line';
      let chartData, chartOptions;

      try {
        chartData = ctrl.dataValue ? JSON.parse(ctrl.dataValue) : ctrl.getDefaultData(chartType);
        chartOptions = ctrl.optionsValue ? JSON.parse(ctrl.optionsValue) : ctrl.getDefaultOptions();
      } catch (error) {
        console.error('Error parsing chart data:', error);
        chartData = ctrl.getDefaultData(chartType);
        chartOptions = ctrl.getDefaultOptions();
      }

      const ctx = ctrl.canvasTarget.getContext('2d');
      ctrl.chart = new Chart(ctx, { type: chartType, data: chartData, options: chartOptions });

      // Set up event listener if event_name is provided
      if (ctrl.hasEventNameValue && ctrl.eventNameValue) {
        window.addEventListener(ctrl.eventNameValue, (e) => {
          if (!ctrl.chart) return;
          const { labels, data } = e.detail;
          ctrl.chart.data.labels = labels;

          if (ctrl.chart.config.type === 'pie' || ctrl.chart.config.type === 'doughnut') {
            ctrl.chart.data.datasets[0].data = data;
          } else {
            ctrl.chart.data.datasets.forEach((dataset, i) => {
              dataset.data = Array.isArray(data[0]) ? data[i] : data;
            });
          }
          ctrl.chart.update('active');
        });
      }
    `
  end
end
