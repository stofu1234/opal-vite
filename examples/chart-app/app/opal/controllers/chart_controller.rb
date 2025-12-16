# backtick_javascript: true

# Chart controller demonstrating Chart.js integration
class ChartController < StimulusController
  include StimulusHelpers

  self.targets = ["canvas"]
  self.values = { type: :string, data: :string, options: :string, event_name: :string }

  # Default chart colors
  CHART_COLORS = [
    'rgba(102, 126, 234, 0.8)',
    'rgba(118, 75, 162, 0.8)',
    'rgba(237, 100, 166, 0.8)',
    'rgba(255, 159, 64, 0.8)',
    'rgba(75, 192, 192, 0.8)',
    'rgba(153, 102, 255, 0.8)'
  ].freeze

  DEFAULT_LABELS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'].freeze
  MONTH_NAMES = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].freeze

  def connect
    puts "Chart controller connected!"
    initialize_chart
  end

  def disconnect
    chart = js_prop(:chart)
    js_call_on(chart, :destroy) if chart
  end

  # Update chart with new data
  def update_chart
    js_call(:randomizeData) if js_has_prop?(:chart)
  end

  # Add new data point
  def add_data
    return unless js_has_prop?(:chart)

    chart = js_prop(:chart)
    labels = js_get(js_get(chart, :data), :labels)
    current_count = js_length(labels)
    new_label = MONTH_NAMES[current_count % 12]
    new_values = [random_int(30), random_int(30)]

    js_call(:addDataPoint, new_label, new_values)
  end

  # Remove last data point
  def remove_data
    js_call(:removeDataPoint)
  end

  private

  def initialize_chart
    # Check if Chart.js is loaded
    unless js_global_exists?('Chart')
      console_error('Chart.js is not loaded!')
      return
    end

    # Define helper functions on controller
    setup_chart_helpers

    # Get chart configuration
    chart_type = js_prop(:typeValue) || 'line'
    chart_data = parse_chart_data(chart_type)
    chart_options = parse_chart_options

    # Create chart instance
    canvas = get_target(:canvas)
    ctx = js_call_on(canvas, :getContext, '2d')
    chart_class = js_global('Chart')
    config = { type: chart_type, data: chart_data, options: chart_options }
    chart = js_new(chart_class, ctx, config.to_n)
    js_set_prop(:chart, chart)

    # Set up event listener if event_name is provided
    setup_chart_event_listener
  end

  def setup_chart_helpers
    # Define getDefaultData function
    js_define_method(:getDefaultData) do |type|
      data1 = [12, 19, 3, 5, 2, 3]
      data2 = [2, 3, 20, 5, 1, 4]

      if `#{type} === 'pie' || #{type} === 'doughnut'`
        {
          labels: DEFAULT_LABELS,
          datasets: [{ data: data1, backgroundColor: CHART_COLORS }]
        }.to_n
      else
        {
          labels: DEFAULT_LABELS,
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
        }.to_n
      end
    end

    # Define getDefaultOptions function
    js_define_method(:getDefaultOptions) do
      {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: true, position: 'top' },
          title: { display: false }
        }
      }.to_n
    end

    # Define addDataPoint function
    js_define_method(:addDataPoint) do |label, values|
      chart = js_prop(:chart)
      next unless chart

      labels = js_get(js_get(chart, :data), :labels)
      `#{labels}.push(#{label})`

      datasets = js_get(js_get(chart, :data), :datasets)
      js_each(datasets) do |dataset, i|
        data_arr = js_get(dataset, :data)
        value = `Array.isArray(#{values}) ? #{values}[#{i}] : #{values}`
        `#{data_arr}.push(#{value})`
      end

      js_call_on(chart, :update)
    end

    # Define removeDataPoint function
    js_define_method(:removeDataPoint) do
      chart = js_prop(:chart)
      next unless chart

      labels = js_get(js_get(chart, :data), :labels)
      `#{labels}.pop()`

      datasets = js_get(js_get(chart, :data), :datasets)
      js_each(datasets) do |dataset|
        data_arr = js_get(dataset, :data)
        `#{data_arr}.pop()`
      end

      js_call_on(chart, :update)
    end

    # Define randomizeData function
    js_define_method(:randomizeData) do
      chart = js_prop(:chart)
      next unless chart

      datasets = js_get(js_get(chart, :data), :datasets)
      js_each(datasets) do |dataset|
        data_arr = js_get(dataset, :data)
        new_data = js_map(data_arr) { random_int(30) }
        js_set(dataset, :data, new_data)
      end

      js_call_on(chart, :update)
    end
  end

  def parse_chart_data(chart_type)
    data_value = js_prop(:dataValue)
    if data_value && `#{data_value} !== ""`
      begin
        json_parse(data_value)
      rescue
        console_error('Error parsing chart data')
        js_call(:getDefaultData, chart_type)
      end
    else
      js_call(:getDefaultData, chart_type)
    end
  end

  def parse_chart_options
    options_value = js_prop(:optionsValue)
    if options_value && `#{options_value} !== ""`
      begin
        json_parse(options_value)
      rescue
        console_error('Error parsing chart options')
        js_call(:getDefaultOptions)
      end
    else
      js_call(:getDefaultOptions)
    end
  end

  def setup_chart_event_listener
    has_event = js_prop(:hasEventNameValue)
    event_name = js_prop(:eventNameValue)

    return unless has_event && event_name

    on_window_event(event_name) do |e|
      chart = js_prop(:chart)
      next unless chart

      detail = `#{e}.detail`
      labels = `#{detail}.labels`
      data = `#{detail}.data`

      chart_data = js_get(chart, :data)
      js_set(chart_data, :labels, labels)

      chart_type = js_get(js_get(chart, :config), :type)

      if `#{chart_type} === 'pie' || #{chart_type} === 'doughnut'`
        datasets = js_get(chart_data, :datasets)
        first_dataset = `#{datasets}[0]`
        js_set(first_dataset, :data, data)
      else
        datasets = js_get(chart_data, :datasets)
        js_each(datasets) do |dataset, i|
          value = `Array.isArray(#{data}[0]) ? #{data}[#{i}] : #{data}`
          js_set(dataset, :data, value)
        end
      end

      js_call_on(chart, :update, 'active')
    end
  end
end
