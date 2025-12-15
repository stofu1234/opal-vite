# backtick_javascript: true

# Chart controller demonstrating Chart.js integration
class ChartController < StimulusController
  self.targets = ["canvas"]
  self.values = { type: :string, data: :string, options: :string, event_name: :string }

  def connect
    puts "Chart controller connected!"

    # Initialize Chart.js
    `
      const ctrl = this;

      // Import Chart.js if not already available
      if (typeof Chart === 'undefined') {
        console.error('Chart.js is not loaded!');
        return;
      }

      // Helper function to get default data for each chart type
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

        switch (type) {
          case 'pie':
          case 'doughnut':
            return {
              labels: labels,
              datasets: [{
                data: data1,
                backgroundColor: colors
              }]
            };
          case 'bar':
          case 'line':
          default:
            return {
              labels: labels,
              datasets: [
                {
                  label: 'Dataset 1',
                  data: data1,
                  backgroundColor: 'rgba(102, 126, 234, 0.5)',
                  borderColor: 'rgba(102, 126, 234, 1)',
                  borderWidth: 2
                },
                {
                  label: 'Dataset 2',
                  data: data2,
                  backgroundColor: 'rgba(118, 75, 162, 0.5)',
                  borderColor: 'rgba(118, 75, 162, 1)',
                  borderWidth: 2
                }
              ]
            };
        }
      };

      // Helper function to get default options for each chart type
      ctrl.getDefaultOptions = function(type) {
        return {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: true,
              position: 'top'
            },
            title: {
              display: false
            }
          }
        };
      };

      // Update chart data
      ctrl.updateData = function(newData) {
        if (!ctrl.chart) return;

        ctrl.chart.data = newData;
        ctrl.chart.update();
      };

      // Add data point
      ctrl.addDataPoint = function(label, values) {
        if (!ctrl.chart) return;

        ctrl.chart.data.labels.push(label);

        ctrl.chart.data.datasets.forEach((dataset, index) => {
          const value = Array.isArray(values) ? values[index] : values;
          dataset.data.push(value);
        });

        ctrl.chart.update();
      };

      // Remove last data point
      ctrl.removeDataPoint = function() {
        if (!ctrl.chart) return;

        ctrl.chart.data.labels.pop();
        ctrl.chart.data.datasets.forEach(dataset => {
          dataset.data.pop();
        });

        ctrl.chart.update();
      };

      // Randomize data
      ctrl.randomizeData = function() {
        if (!ctrl.chart) return;

        ctrl.chart.data.datasets.forEach(dataset => {
          dataset.data = dataset.data.map(() => Math.floor(Math.random() * 30));
        });

        ctrl.chart.update();
      };

      // Now initialize the chart after all helper functions are defined
      // Get chart type from value or default to 'line'
      const chartType = ctrl.typeValue || 'line';

      // Parse data and options from values
      let chartData;
      let chartOptions;

      try {
        chartData = ctrl.dataValue ? JSON.parse(ctrl.dataValue) : ctrl.getDefaultData(chartType);
        chartOptions = ctrl.optionsValue ? JSON.parse(ctrl.optionsValue) : ctrl.getDefaultOptions(chartType);
      } catch (error) {
        console.error('Error parsing chart data or options:', error);
        chartData = ctrl.getDefaultData(chartType);
        chartOptions = ctrl.getDefaultOptions(chartType);
      }

      // Create chart
      const ctx = ctrl.canvasTarget.getContext('2d');

      ctrl.chart = new Chart(ctx, {
        type: chartType,
        data: chartData,
        options: chartOptions
      });

      // If event_name value is provided, listen for custom events to update chart
      if (ctrl.hasEventNameValue && ctrl.eventNameValue) {
        const eventName = ctrl.eventNameValue;
        console.log('Chart: Setting up event listener for', eventName);

        window.addEventListener(eventName, (e) => {
          const { labels, data } = e.detail;

          if (!ctrl.chart) return;

          // Update chart data
          ctrl.chart.data.labels = labels;

          if (ctrl.chart.config.type === 'pie' || ctrl.chart.config.type === 'doughnut') {
            // For pie/doughnut charts, use single dataset
            ctrl.chart.data.datasets[0].data = data;
          } else {
            // For other charts, update all datasets
            ctrl.chart.data.datasets.forEach((dataset, index) => {
              dataset.data = Array.isArray(data[0]) ? data[index] : data;
            });
          }

          ctrl.chart.update('active');
        });
      }
    `
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
    `
      this.removeDataPoint();
    `
  end
end
