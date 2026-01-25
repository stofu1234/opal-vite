# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'FunctionalComponent', type: :feature do
  describe 'create_component' do
    it 'creates a valid React functional component' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = `
              require 'native'
              require 'opal_vite/concerns/v1/react_helpers'
              require 'opal_vite/concerns/v1/functional_component'

              class TestComponent
                extend ReactHelpers
                extend FunctionalComponent

                def self.to_n
                  create_component do |hooks|
                    react.createElement('div', { id: 'test-result' }, 'Component works')
                  end
                end
              end

              TestComponent.to_n
            `;
            var component = Opal.eval(code);
            return {
              success: true,
              isFunction: typeof component === 'function'
            };
          } catch(e) {
            return { success: false, error: e.message, stack: e.stack };
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}\n#{result['stack']}" }
      expect(result['isFunction']).to eq(true)
    end
  end

  describe 'Hooks.use_state' do
    it 'returns current value and setter' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = `
              require 'native'
              require 'opal_vite/concerns/v1/react_helpers'
              require 'opal_vite/concerns/v1/functional_component'

              class StateTestComponent
                extend ReactHelpers
                extend FunctionalComponent

                def self.to_n
                  create_component do |hooks|
                    count, set_count = hooks.use_state(42)
                    react.createElement('div', { id: 'state-test' }, count.to_s)
                  end
                end
              end

              StateTestComponent
            `;
            Opal.eval(code);

            // Render the component
            var container = document.createElement('div');
            container.id = 'state-test-container';
            document.body.appendChild(container);

            var component = Opal.Object.$const_get('StateTestComponent').$to_n();
            var element = React.createElement(component, null);
            var root = ReactDOM.createRoot(container);
            root.render(element);

            // Wait for render
            return new Promise(function(resolve) {
              setTimeout(function() {
                var testEl = document.getElementById('state-test');
                resolve({
                  success: true,
                  value: testEl ? testEl.textContent : null
                });
                root.unmount();
                container.remove();
              }, 100);
            });
          } catch(e) {
            return Promise.resolve({ success: false, error: e.message, stack: e.stack });
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}\n#{result['stack']}" }
      expect(result['value']).to eq('42')
    end
  end

  describe 'StateSetter' do
    it 'updates state with .to() method' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = `
              require 'native'
              require 'opal_vite/concerns/v1/react_helpers'
              require 'opal_vite/concerns/v1/functional_component'

              class SetterTestComponent
                extend ReactHelpers
                extend FunctionalComponent

                def self.to_n
                  create_component do |hooks|
                    count, set_count = hooks.use_state(0)
                    react.createElement('div', nil,
                      react.createElement('span', { id: 'setter-value' }, count.to_s),
                      react.createElement('button', { id: 'setter-btn', onClick: set_count.to(99) }, 'Set')
                    )
                  end
                end
              end

              SetterTestComponent
            `;
            Opal.eval(code);

            var container = document.createElement('div');
            container.id = 'setter-test-container';
            document.body.appendChild(container);

            var component = Opal.Object.$const_get('SetterTestComponent').$to_n();
            var element = React.createElement(component, null);
            var root = ReactDOM.createRoot(container);
            root.render(element);

            return new Promise(function(resolve) {
              setTimeout(function() {
                var initialValue = document.getElementById('setter-value').textContent;
                document.getElementById('setter-btn').click();

                setTimeout(function() {
                  var newValue = document.getElementById('setter-value').textContent;
                  resolve({
                    success: true,
                    initialValue: initialValue,
                    newValue: newValue
                  });
                  root.unmount();
                  container.remove();
                }, 100);
              }, 100);
            });
          } catch(e) {
            return Promise.resolve({ success: false, error: e.message, stack: e.stack });
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}\n#{result['stack']}" }
      expect(result['initialValue']).to eq('0')
      expect(result['newValue']).to eq('99')
    end

    it 'updates state with .with() functional update' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = `
              require 'native'
              require 'opal_vite/concerns/v1/react_helpers'
              require 'opal_vite/concerns/v1/functional_component'

              class FunctionalUpdateComponent
                extend ReactHelpers
                extend FunctionalComponent

                def self.to_n
                  create_component do |hooks|
                    count, set_count = hooks.use_state(10)
                    react.createElement('div', nil,
                      react.createElement('span', { id: 'func-value' }, count.to_s),
                      react.createElement('button', { id: 'func-btn', onClick: set_count.with { |c| c + 5 } }, 'Add')
                    )
                  end
                end
              end

              FunctionalUpdateComponent
            `;
            Opal.eval(code);

            var container = document.createElement('div');
            container.id = 'func-test-container';
            document.body.appendChild(container);

            var component = Opal.Object.$const_get('FunctionalUpdateComponent').$to_n();
            var element = React.createElement(component, null);
            var root = ReactDOM.createRoot(container);
            root.render(element);

            return new Promise(function(resolve) {
              setTimeout(function() {
                var initialValue = document.getElementById('func-value').textContent;
                document.getElementById('func-btn').click();

                setTimeout(function() {
                  var afterFirstClick = document.getElementById('func-value').textContent;
                  document.getElementById('func-btn').click();

                  setTimeout(function() {
                    var afterSecondClick = document.getElementById('func-value').textContent;
                    resolve({
                      success: true,
                      initialValue: initialValue,
                      afterFirstClick: afterFirstClick,
                      afterSecondClick: afterSecondClick
                    });
                    root.unmount();
                    container.remove();
                  }, 100);
                }, 100);
              }, 100);
            });
          } catch(e) {
            return Promise.resolve({ success: false, error: e.message, stack: e.stack });
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}\n#{result['stack']}" }
      expect(result['initialValue']).to eq('10')
      expect(result['afterFirstClick']).to eq('15')
      expect(result['afterSecondClick']).to eq('20')
    end
  end

  describe 'Counter component using FunctionalComponent' do
    it 'renders with initial state' do
      expect(page).to have_css('.count-value', text: '0')
    end

    it 'increments using set_count.with' do
      find('.btn-increment').click
      expect(page).to have_css('.count-value', text: '1')
    end

    it 'decrements using set_count.with' do
      find('.btn-decrement').click
      expect(page).to have_css('.count-value', text: '-1')
    end

    it 'resets using set_count.to' do
      3.times { find('.btn-increment').click }
      expect(page).to have_css('.count-value', text: '3')

      find('.btn-reset').click
      expect(page).to have_css('.count-value', text: '0')
    end
  end
end
