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
      require 'opal_vite/concerns/v1/base64_helpers'
      require 'opal_vite/concerns/v1/uri_helpers'
      require 'opal_vite/concerns/v1/action_cable_helpers'

      class Helpers
        include OpalVite::Concerns::V1::StimulusHelpers
        include OpalVite::Concerns::V1::TurboHelpers
        include OpalVite::Concerns::V1::Base64Helpers
        include OpalVite::Concerns::V1::URIHelpers
        include OpalVite::Concerns::V1::ActionCableHelpers
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

  it 'escapes the target of turbo streams' do
    result = run_opal(fake_dom, <<~'RUBY')
      streams = []
      `window.Turbo = { renderStreamMessage: function(html) { #{streams}.push(html); } }`
      h = Helpers.new
      h.turbo_stream(:append, 'a" onclick="x', '<b>ok</b>')
      builder = OpalVite::Concerns::V1::TurboStreamBuilder.new
      builder.remove('r"><script>')
      builder.render
      `console.log(JSON.stringify(#{streams.to_n}))`
    RUBY

    expect(result[0]).to eq('<turbo-stream action="append" target="a&quot; onclick=&quot;x"><template><b>ok</b></template></turbo-stream>')
    expect(result[1]).to eq('<turbo-stream action="remove" target="r&quot;&gt;&lt;script&gt;"></turbo-stream>')
  end

  it 'deep_merge skips prototype keys and storage_get_json tolerates broken JSON' do
    result = run_opal(fake_dom, <<~'RUBY')
      store = { 'bad' => '{oops', 'good' => '{"a":1}' }
      `globalThis.localStorage = { getItem: function(k) { var v = #{store.to_n}[k]; return v === undefined ? null : v; } }`
      h = Helpers.new
      merged = h.deep_merge(Native(`{ a: { x: 1 } }`), Native(`JSON.parse('{"a":{"y":2},"__proto__":{"polluted":true},"constructor":{"z":1}}')`))
      results = {
        a: `JSON.stringify(#{merged}.a)`,
        proto: `Object.getPrototypeOf(#{merged}) === Object.prototype && #{merged}.polluted === undefined`,
        ctor: `Object.prototype.hasOwnProperty.call(#{merged}, 'constructor')`,
        bad: h.storage_get_json('bad', 'fallback'),
        good: `JSON.stringify(#{h.storage_get_json('good')})`,
        missing: h.storage_get_json('missing', 'none')
      }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq('a' => '{"x":1,"y":2}', 'proto' => true, 'ctor' => false,
                         'bad' => 'fallback', 'good' => '{"a":1}', 'missing' => 'none')
  end

  it 'handles non-Latin-1 text in Basic auth and JWT payloads' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      header = h.basic_auth_header('ユーザー', 'pässwörd')
      raw = `unescape(encodeURIComponent('{"name":"日本語"}'))`
      payload = h.base64_encode_urlsafe(raw)
      out = {
        header: header,
        parsed: h.parse_basic_auth(header),
        ascii: h.basic_auth_header('user', 'pass'),
        jwt: h.decode_jwt_payload("x.#{payload}.y")
      }
      `console.log(JSON.stringify({ header: #{out[:header]}, parsed: #{out[:parsed].to_n}, ascii: #{out[:ascii]}, jwt: #{out[:jwt]} }))`
    RUBY

    expect(result['header']).to start_with('Basic ')
    expect(result['header'].length).to be > 'Basic '.length
    expect(result['parsed']).to eq('username' => 'ユーザー', 'password' => 'pässwörd')
    expect(result['ascii']).to eq('Basic dXNlcjpwYXNz')
    expect(result['jwt']).to eq('name' => '日本語')
  end

  it 'keeps the leading slash in join_path and path_dirname' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      results = [
        h.join_path('/api', 'users'), h.join_path('api', '/users/'), h.join_path('a', 'b'),
        h.path_dirname('/file.txt'), h.path_dirname('/a/b/file.txt'), h.path_dirname('a/b.txt'), h.path_dirname('b.txt')
      ]
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq(['/api/users', 'api/users', 'a/b', '/', '/a/b', 'a', ''])
  end

  it 'routes cable data with a numeric type and replaces a repeated subscription' do
    result = run_opal(fake_dom, <<~'RUBY')
      created = 0
      unsubscribed = 0
      consumer = `{ subscriptions: { create: function() { #{created += 1}; return { unsubscribe: function() { #{unsubscribed += 1}; } }; } } }`
      h = Helpers.new
      h.instance_variable_set(:@_cable_consumer, consumer)
      h.subscribe_to('ChatChannel', room: 1)
      h.subscribe_to('ChatChannel', room: 1)
      h.cable_subscribe('ChatChannel', params: { room: 1 })
      hit = nil
      h.cable_route(`{ type: 5 }`, { '5' => -> { hit = 'five' } })
      sym = nil
      h.cable_route(`{ type: 'msg' }`, { msg: -> { sym = 'msg' } })
      `console.log(JSON.stringify({ created: #{created}, unsubscribed: #{unsubscribed}, hit: #{hit}, sym: #{sym} }))`
    RUBY

    expect(result).to eq('created' => 3, 'unsubscribed' => 2, 'hit' => 'five', 'sym' => 'msg')
  end

  it 'unwraps a Native-wrapped event passed with evt:' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      wrapped = Native(`{ key: 'Enter', params: { id: 3 }, preventDefault: function() { this.prevented = true; } }`)
      h.prevent_default(evt: wrapped)
      results = { key: h.event_key(evt: wrapped), id: h.action_param(:id, evt: wrapped), prevented: `#{wrapped.to_n}.prevented` }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq('key' => 'Enter', 'id' => 3, 'prevented' => true)
  end

  it 'reads the event passed in instead of window.event' do
    result = run_opal(fake_dom, <<~'RUBY')
      h = Helpers.new
      evt = `{ key: 'Enter', params: { id: 7 }, currentTarget: { getAttribute: function(n) { return n + '!'; } }, preventDefault: function() { this.prevented = true; } }`
      h.prevent_default(evt: evt)
      `window.event = { key: 'global' }`
      results = {
        key: h.event_key(evt: evt), global: h.event_key, id: h.action_param(:id, evt: evt),
        data: h.event_data('x', evt: evt), has: h.has_action_param?(:id, evt: evt), prevented: `#{evt}.prevented`
      }
      `console.log(JSON.stringify(#{results.to_n}))`
    RUBY

    expect(result).to eq('key' => 'Enter', 'global' => 'global', 'id' => 7, 'data' => 'data-x!', 'has' => true, 'prevented' => true)
  end
end
