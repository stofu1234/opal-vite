# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Chart Dashboard', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'Data Visualization Dashboard')
    end

    it 'displays the subtitle' do
      expect(page).to have_css('.subtitle', text: 'Real-time charts')
    end

    it 'displays the refresh button' do
      expect(page).to have_css('.refresh-btn', text: 'Refresh Data')
    end

    it 'displays the info section' do
      expect(page).to have_css('.info-section h3', text: 'About This Dashboard')
    end

    it 'displays the footer' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Chart.js')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Vite')
    end
  end

  describe 'chart cards' do
    it 'displays four chart cards' do
      expect(page).to have_css('.chart-card', count: 4)
    end

    it 'displays pie chart card' do
      expect(page).to have_css('.chart-card h2', text: 'Users by Company')
      expect(page).to have_css('.chart-type', text: 'Pie Chart')
    end

    it 'displays doughnut chart card' do
      expect(page).to have_css('.chart-card h2', text: 'Users by City')
      expect(page).to have_css('.chart-type', text: 'Doughnut Chart')
    end

    it 'displays bar chart card' do
      expect(page).to have_css('.chart-card h2', text: 'Weekly Activity')
      expect(page).to have_css('.chart-type', text: 'Bar Chart')
    end

    it 'displays line chart card' do
      expect(page).to have_css('.chart-card h2', text: 'Interactive Chart')
      expect(page).to have_css('.chart-type', text: 'Line Chart')
    end
  end

  describe 'canvas elements' do
    it 'has canvas elements for all charts' do
      expect(page).to have_css('[data-chart-target="canvas"]', count: 4)
    end

    it 'each chart card has a canvas' do
      all('.chart-card').each do |card|
        expect(card).to have_css('canvas')
      end
    end
  end

  describe 'interactive chart controls' do
    it 'displays control buttons for interactive chart' do
      expect(page).to have_css('.chart-controls')
      expect(page).to have_css('.control-btn', text: 'Randomize')
      expect(page).to have_css('.control-btn', text: 'Add Data')
      expect(page).to have_css('.control-btn', text: 'Remove Data')
    end

    it 'randomize button is clickable' do
      randomize_btn = find('.control-btn', text: 'Randomize')
      expect { randomize_btn.click }.not_to raise_error
    end

    it 'add data button is clickable' do
      add_btn = find('.control-btn', text: 'Add Data')
      expect { add_btn.click }.not_to raise_error
    end

    it 'remove data button is clickable' do
      remove_btn = find('.control-btn', text: 'Remove Data')
      expect { remove_btn.click }.not_to raise_error
    end
  end

  describe 'refresh functionality' do
    it 'refresh button is clickable' do
      refresh_btn = find('.refresh-btn')
      expect { refresh_btn.click }.not_to raise_error
    end
  end

  describe 'info section content' do
    it 'describes real-time data feature' do
      expect(page).to have_css('.info-item h4', text: 'Real-time Data')
    end

    it 'describes interactive controls feature' do
      expect(page).to have_css('.info-item h4', text: 'Interactive Controls')
    end

    it 'describes multiple chart types feature' do
      expect(page).to have_css('.info-item h4', text: 'Multiple Chart Types')
    end

    it 'describes event-driven updates feature' do
      expect(page).to have_css('.info-item h4', text: 'Event-Driven Updates')
    end
  end

  describe 'statistics cards' do
    it 'displays stats grid' do
      expect(page).to have_css('.stats-grid')
    end

    it 'displays stat cards' do
      expect(page).to have_css('.stat-card', minimum: 1)
    end
  end

  describe 'Chart.js integration' do
    it 'loads Chart.js library' do
      result = page.evaluate_script('typeof Chart !== "undefined"')
      expect(result).to be true
    end

    it 'charts are initialized' do
      # Wait for charts to render
      sleep 2
      wait_for_dom_stable

      # Check if Chart instances exist on canvases
      result = page.evaluate_script(<<~JS)
        (function() {
          var canvases = document.querySelectorAll('[data-chart-target="canvas"]');
          var chartCount = 0;
          canvases.forEach(function(canvas) {
            var chart = Chart.getChart(canvas);
            if (chart) chartCount++;
          });
          return chartCount;
        })()
      JS

      expect(result).to be >= 1
    end
  end

  describe 'loading state' do
    it 'has loading overlay element' do
      loading = find('[data-dashboard-target="loading"]', visible: :all)
      expect(loading).to be_truthy
    end
  end
end
