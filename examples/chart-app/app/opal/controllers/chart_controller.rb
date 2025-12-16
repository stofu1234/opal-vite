# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

# Chart controller demonstrating Chart.js integration
class ChartController < StimulusController
  include JsProxyEx
  include DomHelpers

  self.targets = %w[canvas]
  self.values = { type: :string, data: :string, options: :string, event_name: :string }

  MONTH_NAMES = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].freeze

  # Value accessors (Stimulus values use camelCase in JavaScript)
  def type_value
    `this.typeValue || ''`
  end

  def data_value
    `this.dataValue || ''`
  end

  def options_value
    `this.optionsValue || ''`
  end

  def event_name_value
    `this.eventNameValue || ''`
  end

  def has_event_name_value?
    `this.hasEventNameValue`
  end

  DEFAULT_COLORS = [
    'rgba(102, 126, 234, 0.8)',
    'rgba(118, 75, 162, 0.8)',
    'rgba(237, 100, 166, 0.8)',
    'rgba(255, 159, 64, 0.8)',
    'rgba(75, 192, 192, 0.8)',
    'rgba(153, 102, 255, 0.8)'
  ].freeze

  def initialize
    super
    @chart = nil
  end

  def connect
    puts 'Chart controller connected!'
    return unless chart_js_available?

    initialize_chart
    setup_event_listener if has_event_name_value? && !event_name_value.empty?
  end

  def disconnect
    destroy_chart
  end

  # Stimulus action: Update chart with random data
  def update_chart
    return unless @chart

    randomize_data
  end

  # Stimulus action: Add new data point
  def add_data
    return unless @chart

    current_labels_count = `#{@chart}.data.labels.length`
    new_label = MONTH_NAMES[current_labels_count % 12]
    new_values = [random_value, random_value]

    add_data_point(new_label, new_values)
  end

  # Stimulus action: Remove last data point
  def remove_data
    return unless @chart

    remove_data_point
  end

  private

  def chart_js_available?
    available = `typeof Chart !== 'undefined'`
    unless available
      puts 'Chart.js is not loaded!'
    end
    available
  end

  def initialize_chart
    chart_type = type_value.empty? ? 'line' : type_value
    data_val = data_value
    opts_val = options_value
    ctx = canvas_target.to_n
    labels = MONTH_NAMES[0..5].to_n
    data1 = [12, 19, 3, 5, 2, 3].to_n
    data2 = [2, 3, 20, 5, 1, 4].to_n
    colors = DEFAULT_COLORS.to_n

    @chart = `(function() {
      var chartData;
      var chartOptions;

      // Parse data if provided, otherwise use defaults
      if (data_val && data_val.length > 0) {
        try {
          chartData = JSON.parse(data_val);
        } catch(e) {
          chartData = null;
        }
      }

      if (!chartData) {
        if (chart_type === 'pie' || chart_type === 'doughnut') {
          chartData = {
            labels: labels,
            datasets: [{
              data: data1,
              backgroundColor: colors
            }]
          };
        } else {
          chartData = {
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
      }

      // Parse options if provided, otherwise use defaults
      if (opts_val && opts_val.length > 0) {
        try {
          chartOptions = JSON.parse(opts_val);
        } catch(e) {
          chartOptions = null;
        }
      }

      if (!chartOptions) {
        chartOptions = {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { display: true, position: 'top' },
            title: { display: false }
          }
        };
      }

      return new Chart(ctx.getContext('2d'), {
        type: chart_type,
        data: chartData,
        options: chartOptions
      });
    })()`
  end

  def destroy_chart
    return unless @chart

    chart = @chart
    `chart.destroy()`
    @chart = nil
  end

  def setup_event_listener
    event_name = event_name_value
    puts "Chart: Setting up event listener for #{event_name}"

    chart = @chart
    `
      window.addEventListener(event_name, function(e) {
        const { labels, data } = e.detail;
        if (!chart) return;

        chart.data.labels = labels;

        if (chart.config.type === 'pie' || chart.config.type === 'doughnut') {
          chart.data.datasets[0].data = data;
        } else {
          chart.data.datasets.forEach(function(dataset, index) {
            dataset.data = Array.isArray(data[0]) ? data[index] : data;
          });
        }

        chart.update('active');
      });
    `
  end

  def randomize_data
    chart = @chart
    `
      chart.data.datasets.forEach(function(dataset) {
        dataset.data = dataset.data.map(function() {
          return Math.floor(Math.random() * 30);
        });
      });
      chart.update();
    `
  end

  def add_data_point(label, values)
    chart = @chart
    values_js = values.to_n
    `
      chart.data.labels.push(label);
      chart.data.datasets.forEach(function(dataset, index) {
        const value = values_js[index] || values_js;
        dataset.data.push(value);
      });
      chart.update();
    `
  end

  def remove_data_point
    chart = @chart
    `
      chart.data.labels.pop();
      chart.data.datasets.forEach(function(dataset) {
        dataset.data.pop();
      });
      chart.update();
    `
  end

  def random_value
    `Math.floor(Math.random() * 30)`
  end
end
