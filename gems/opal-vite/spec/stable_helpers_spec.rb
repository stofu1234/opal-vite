require 'spec_helper'
require 'opal/vite/testing/stable_helpers'

RSpec.describe Opal::Vite::Testing::StableHelpers do
  let(:scripts) { [] }
  let(:host) do
    captured = scripts
    Class.new do
      include Opal::Vite::Testing::StableHelpers
      define_method(:page) do
        Object.new.tap do |page|
          page.define_singleton_method(:evaluate_script) do |js|
            captured << js
            { 'success' => true }
          end
        end
      end
    end.new
  end

  it 'escapes the value of stable_set once' do
    host.stable_set('#name', %q(it's a \ test))

    expect(scripts.last).to include(%q(el.value = 'it\'s a \\\\ test';))
  end
end
