# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Stimulus + Opal + Vite', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'Stimulus + Opal + Vite')
    end

    it 'displays the subtitle' do
      expect(page).to have_css('.subtitle', text: 'Write Stimulus controllers in Ruby!')
    end

    it 'displays the footer with links' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Vite')
    end

    it 'displays all four controller sections' do
      expect(page).to have_css('[data-controller="hello"]')
      expect(page).to have_css('[data-controller="counter"]')
      expect(page).to have_css('[data-controller="clipboard"]')
      expect(page).to have_css('[data-controller="slideshow"]')
    end
  end

  describe 'Hello Controller' do
    let(:name_input) { '[data-hello-target="name"]' }
    let(:output) { '[data-hello-target="output"]' }
    let(:greet_btn) { '[data-action="click->hello#greet"]' }

    it 'has an input with default value "World"' do
      input = find(name_input)
      expect(input.value).to eq('World')
    end

    it 'displays greeting when clicking greet button' do
      stable_click(greet_btn)
      sleep 0.5
      wait_for_dom_stable

      wait_for_text(output, 'Hello, World!')
    end

    it 'greets with custom name' do
      find(name_input).set('Opal')
      stable_click(greet_btn)
      sleep 0.5
      wait_for_dom_stable

      wait_for_text(output, 'Hello, Opal!')
    end

    it 'greets with empty name' do
      find(name_input).set('')
      stable_click(greet_btn)
      sleep 0.5
      wait_for_dom_stable

      wait_for_text(output, 'Hello, !')
    end
  end

  describe 'Counter Controller' do
    let(:display) { '[data-counter-target="display"]' }
    let(:increment_btn) { '[data-action="click->counter#increment"]' }
    let(:decrement_btn) { '[data-action="click->counter#decrement"]' }
    let(:reset_btn) { '[data-action="click->counter#reset"]' }

    it 'displays initial count of 0' do
      expect(page).to have_css(display, text: '0')
    end

    it 'increments the counter' do
      stable_click(increment_btn)
      sleep 0.3
      wait_for_dom_stable
      wait_for_text(display, '1')

      stable_click(increment_btn)
      sleep 0.3
      wait_for_dom_stable
      wait_for_text(display, '2')
    end

    it 'decrements the counter' do
      stable_click(decrement_btn)
      sleep 0.3
      wait_for_dom_stable
      wait_for_text(display, '-1')
    end

    it 'resets the counter to zero' do
      # Increment a few times
      3.times do
        stable_click(increment_btn)
        sleep 0.3
        wait_for_dom_stable
      end
      wait_for_text(display, '3')

      # Reset
      stable_click(reset_btn)
      sleep 0.3
      wait_for_dom_stable
      wait_for_text(display, '0')
    end

    it 'handles multiple operations correctly' do
      stable_click(increment_btn)
      sleep 0.3
      wait_for_dom_stable
      stable_click(increment_btn)
      sleep 0.3
      wait_for_dom_stable
      stable_click(decrement_btn)
      sleep 0.3
      wait_for_dom_stable

      wait_for_text(display, '1')
    end
  end

  describe 'Clipboard Controller' do
    let(:source_input) { '[data-clipboard-target="source"]' }
    let(:copy_btn) { '[data-clipboard-target="button"]' }

    it 'displays the source text input' do
      input = find(source_input)
      expect(input.value).to eq('Hello from Stimulus + Opal!')
      expect(input[:readonly]).to be_truthy
    end

    it 'has clipboard-supported class when clipboard API is available' do
      clipboard_section = find('[data-controller="clipboard"]')
      # Modern browsers support clipboard API
      expect(clipboard_section[:class]).to include('clipboard-supported')
    end

    it 'changes button text after copying' do
      stable_click(copy_btn)
      wait_for_dom_stable

      # Button text should change to "Copied!"
      expect(page).to have_css(copy_btn, text: 'Copied!')

      # Wait for it to revert back (after 2 seconds)
      sleep 2.5
      expect(page).to have_css(copy_btn, text: 'Copy to Clipboard')
    end
  end

  describe 'Slideshow Controller' do
    let(:slides) { '[data-slideshow-target="slide"]' }
    let(:next_btn) { '[data-action="click->slideshow#next"]' }
    let(:previous_btn) { '[data-action="click->slideshow#previous"]' }

    it 'displays three slides' do
      # Slides use opacity:0 for hidden, so use visible: :all
      expect(page).to have_css(slides, count: 3, visible: :all)
    end

    it 'has first slide active initially' do
      all_slides = all(slides, visible: :all)
      expect(all_slides[0][:class]).to include('slide-active')
      expect(all_slides[1][:class]).not_to include('slide-active')
      expect(all_slides[2][:class]).not_to include('slide-active')
    end

    it 'navigates to next slide' do
      stable_click(next_btn)
      sleep 0.6  # Wait for transition (0.5s)
      wait_for_dom_stable

      all_slides = all(slides, visible: :all)
      expect(all_slides[0][:class]).not_to include('slide-active')
      expect(all_slides[1][:class]).to include('slide-active')
      expect(all_slides[2][:class]).not_to include('slide-active')
    end

    it 'navigates to previous slide' do
      # First go to slide 2
      stable_click(next_btn)
      sleep 0.6
      wait_for_dom_stable

      # Then go back to slide 1
      stable_click(previous_btn)
      sleep 0.6
      wait_for_dom_stable

      all_slides = all(slides, visible: :all)
      expect(all_slides[0][:class]).to include('slide-active')
    end

    it 'wraps around to first slide from last' do
      # Go to last slide (3 clicks from 0 -> 1 -> 2 -> 0)
      3.times do
        stable_click(next_btn)
        sleep 0.6
        wait_for_dom_stable
      end

      # Should be back to first slide
      all_slides = all(slides, visible: :all)
      expect(all_slides[0][:class]).to include('slide-active')
    end

    it 'wraps around to last slide from first' do
      stable_click(previous_btn)
      sleep 0.6
      wait_for_dom_stable

      # Should be on last slide
      all_slides = all(slides, visible: :all)
      expect(all_slides[2][:class]).to include('slide-active')
    end

    it 'displays correct slide content' do
      # First slide is visible
      expect(page).to have_css('.slide-active .slide-content h3', text: 'Slide 1')

      stable_click(next_btn)
      sleep 0.6
      wait_for_dom_stable
      expect(page).to have_css('.slide-active .slide-content h3', text: 'Slide 2')

      stable_click(next_btn)
      sleep 0.6
      wait_for_dom_stable
      expect(page).to have_css('.slide-active .slide-content h3', text: 'Slide 3')
    end
  end
end
