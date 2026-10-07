require 'spec_helper'
require 'json'
require 'tempfile'

# Runs built-in helpers under node with a minimal fake document, since these
# behaviors only show up at runtime.
RSpec.describe 'OpalVite::Concerns::V1 helpers' do
  node_available = system('node --version', out: File::NULL, err: File::NULL)

  fake_dom = <<~JS
    var window = globalThis;
    globalThis.__listeners = 0;
    globalThis.document = {
      addEventListener: function() { globalThis.__listeners++; },
      removeEventListener: function() { globalThis.__listeners--; }
    };
  JS

  def run_opal(fake_dom, ruby)
    source = <<~RUBY
      require 'native'
      require 'opal_vite/concerns/v1/stimulus_helpers'
      require 'opal_vite/concerns/v1/turbo_helpers'
      require 'opal_vite/concerns/v1/js_proxy_ex'
      require 'opal_vite/concerns/v1/component'

      class Helpers
        include OpalVite::Concerns::V1::StimulusHelpers
        include OpalVite::Concerns::V1::TurboHelpers
      end

      #{ruby}
    RUBY
    code = Opal::Vite::Compiler.new(external_runtime: true).compile(source, 'entry.rb')[:code]
    Tempfile.create(['helpers', '.js']) do |file|
      file.write(fake_dom)
      file.write(Opal::Vite::Compiler.runtime_code)
      file.write(code)
      file.flush
      output = `node #{file.path} 2>&1`
      expect($?.success?).to be(true), output
      JSON.parse(output.lines.last)
    end
  end

  before { skip 'node is not installed' unless node_available }

  it 'escapes HTML with escape_html' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      results = {
        markup: h.escape_html(%q{<a href="x">'&'</a>}),
        ruby_nil: h.escape_html(nil),
        js_null: h.escape_html(`null`),
        number: h.escape_html(5),
        js_object: h.escape_html(`{ toString: function() { return '<js>'; } }`),
        component: OpalComponent.new.escape_html('<b>')
      }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq(
      'markup' => '&lt;a href=&quot;x&quot;&gt;&#39;&amp;&#39;&lt;/a&gt;',
      'ruby_nil' => '', 'js_null' => '', 'number' => '5', 'js_object' => '&lt;js&gt;', 'component' => '&lt;b&gt;'
    )
  end

  it 'treats JS null as blank in the validation helpers' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      results = {
        blank: h.blank?(`null`),
        present: h.present?(`undefined`),
        min_length: h.min_length?(`null`, 1),
        max_length: h.max_length?(`undefined`, 3),
        pattern: h.matches_pattern?(`null`, 'a'),
        phone: h.valid_phone?(`null`)
      }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq('blank' => true, 'present' => false, 'min_length' => false,
                         'max_length' => false, 'pattern' => false, 'phone' => false)
  end

  it 'removes on_turbo listeners with off_turbo and off_all_turbo' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      load_handler = h.on_turbo('load') { nil }
      h.on_turbo('visit') { nil }
      h.turbo_loading_class(Native(`{ classList: { add: function() {}, remove: function() {} } }`))
      added = `globalThis.__listeners`
      h.off_turbo('load', load_handler)
      after_off = `globalThis.__listeners`
      h.off_all_turbo
      after_all = `globalThis.__listeners`
      `console.log(JSON.stringify({ added: #{added}, after_off: #{after_off}, after_all: #{after_all} }))`
    RUBY

    expect(result).to eq('added' => 4, 'after_off' => 3, 'after_all' => 0)
  end

  it 'calls methods for predicate names on JsObject' do
    result = run_opal(fake_dom, <<~'RUBY')
      el = OpalVite::Concerns::V1::JsProxyEx::JsObject.new(`{ hasAttribute: function(n) { return n === 'x'; }, disabled: false }`)
      results = { has_x: el.has_attribute?('x'), has_y: el.has_attribute?('y'), disabled: el.disabled? }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq('has_x' => true, 'has_y' => false, 'disabled' => false)
  end
end
