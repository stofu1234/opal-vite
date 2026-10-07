require 'spec_helper'
require 'json'
require 'tempfile'

# Runs the compiled FunctionalComponent under node against a minimal fake
# React, since a syntax check alone does not catch a missing return value.
RSpec.describe 'OpalVite::Concerns::V1::FunctionalComponent' do
  node_available = system('node --version', out: File::NULL, err: File::NULL)

  # A fake React that records hook calls. useState keeps one slot per call
  # order, like React does within a component.
  fake_react = <<~JS
    var window = globalThis;
    globalThis.__log = [];
    globalThis.__state = [];
    globalThis.React = {
      useState: function(initial) {
        var i = globalThis.__hookIndex++;
        if (!(i in globalThis.__state)) globalThis.__state[i] = initial;
        return [globalThis.__state[i], function(next) {
          globalThis.__state[i] = typeof next === 'function' ? next(globalThis.__state[i]) : next;
        }];
      },
      useEffect: function(fn) { globalThis.__log.push({ cleanup: typeof fn() }); },
      useReducer: function(reducer, initial) {
        return [initial, function(action) { globalThis.__log.push({ reduced: reducer(initial, action) }); }];
      }
    };
    globalThis.render = function(component) {
      globalThis.__hookIndex = 0;
      return component({});
    };
  JS

  def run_component(fake_react, ruby)
    source = <<~RUBY
      require 'native'
      require 'opal_vite/concerns/v1/react_helpers'
      require 'opal_vite/concerns/v1/functional_component'
      #{ruby}
    RUBY
    code = Opal::Vite::Compiler.new(external_runtime: true).compile(source, 'entry.rb')[:code]
    Tempfile.create(['functional_component', '.js']) do |file|
      file.write(fake_react)
      file.write(Opal::Vite::Compiler.runtime_code)
      file.write(code)
      file.flush
      output = `node #{file.path} 2>&1`
      expect($?.success?).to be(true), output
      JSON.parse(output.lines.last)
    end
  end

  before { skip 'node is not installed' unless node_available }

  it 'returns a function component whose use_state setter updates state' do
    result = run_component(fake_react, <<~'RUBY')
      class Counter
        extend ReactHelpers
        extend FunctionalComponent

        def self.to_n
          create_component do |hooks|
            count, set_count = hooks.use_state(0)
            `{ count: #{count}, increment: #{set_count.with { |c| c + 1 }}, reset: #{set_count.to(0)} }`
          end
        end
      end

      `
        var component = #{Counter.to_n};
        var first = render(component);
        first.increment();
        first.increment();
        var second = render(component);
        second.reset();
        var third = render(component);
        console.log(JSON.stringify({
          type: typeof component, first: first.count, second: second.count, third: third.count
        }));
      `
    RUBY

    expect(result).to eq('type' => 'function', 'first' => 0, 'second' => 2, 'third' => 0)
  end

  it 'unwraps the Native element the block returns' do
    result = run_component(fake_react, <<~'RUBY')
      class Wrapped
        extend ReactHelpers
        extend FunctionalComponent

        def self.to_n
          create_component { |_hooks| Native(`{ tag: 'div' }`) }
        end
      end

      `
        var element = render(#{Wrapped.to_n});
        console.log(JSON.stringify({ tag: element.tag, wrapped: '$$id' in element }));
      `
    RUBY

    expect(result).to eq('tag' => 'div', 'wrapped' => false)
  end

  it 'gives React a cleanup function or undefined from use_effect' do
    result = run_component(fake_react, <<~'RUBY')
      class Effects
        extend ReactHelpers
        extend FunctionalComponent

        def self.to_n
          create_component do |hooks|
            hooks.use_effect([]) { nil }
            hooks.use_effect([]) { -> { nil } }
            nil
          end
        end
      end

      `
        render(#{Effects.to_n});
        console.log(JSON.stringify(globalThis.__log));
      `
    RUBY

    expect(result).to eq([{ 'cleanup' => 'undefined' }, { 'cleanup' => 'function' }])
  end

  it 'passes Ruby-friendly state and action to the use_reducer reducer' do
    result = run_component(fake_react, <<~'RUBY')
      class Reducer
        extend ReactHelpers
        extend FunctionalComponent

        def self.to_n
          create_component do |hooks|
            reducer = ->(state, action) { { count: state[:count] + action[:by] } }
            _state, dispatch = hooks.use_reducer(reducer, { count: 1 })
            dispatch.call({ by: 2 })
            nil
          end
        end
      end

      `
        render(#{Reducer.to_n});
        console.log(JSON.stringify(globalThis.__log));
      `
    RUBY

    expect(result).to eq([{ 'reduced' => { 'count' => 3 } }])
  end
end
