# backtick_javascript: true

# Data chart controller that extends chart controller with event listening
class DataChartController < ChartController
  self.values = { event_name: :string }

  def connect
    super

    # Listen for custom events to update chart
    `
      const ctrl = this;
      const eventName = ctrl.eventNameValue || 'update-chart';

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
    `
  end
end
