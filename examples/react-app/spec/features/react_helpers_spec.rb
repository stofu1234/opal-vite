# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'ReactHelpers', type: :feature do
  describe 'query_all' do
    it 'returns an array that can be inspected' do
      # Call query_all and try to inspect the result
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            // Execute Ruby code that uses query_all and calls inspect
            var code = 'include ReactHelpers; query_all("div").inspect';
            var evalResult = Opal.eval(code);
            return { success: true, result: evalResult, type: typeof evalResult };
          } catch(e) {
            return { success: false, error: e.message, stack: e.stack };
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}\n#{result['stack']}" }
      expect(result['result']).to be_a(String)
      # The result should be a proper Ruby array representation
      expect(result['result']).to match(/^\[.*\]$/)
    end

    it 'returns an array with length method' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = 'include ReactHelpers; query_all("div").length';
            var evalResult = Opal.eval(code);
            return { success: true, result: evalResult };
          } catch(e) {
            return { success: false, error: e.message };
          }
        })()
      JS

      expect(result['success']).to eq(true)
      expect(result['result']).to be_a(Integer)
      expect(result['result']).to be > 0
    end

    it 'returns an array that can be iterated with each' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = 'include ReactHelpers; count = 0; query_all("div").each { |el| count += 1 }; count';
            var evalResult = Opal.eval(code);
            return { success: true, result: evalResult };
          } catch(e) {
            return { success: false, error: e.message };
          }
        })()
      JS

      expect(result['success']).to eq(true)
      expect(result['result']).to be_a(Integer)
      expect(result['result']).to be > 0
    end

    it 'returns an array with first and last methods' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = 'include ReactHelpers; arr = query_all("div"); arr.first != nil && arr.last != nil';
            var evalResult = Opal.eval(code);
            return { success: true, result: evalResult };
          } catch(e) {
            return { success: false, error: e.message };
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}" }
      expect(result['result']).to eq(true)
    end
  end

  describe 'query' do
    it 'returns a single element' do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            var code = 'include ReactHelpers; !query("#root").nil?';
            var evalResult = Opal.eval(code);
            return { success: true, result: evalResult };
          } catch(e) {
            return { success: false, error: e.message };
          }
        })()
      JS

      expect(result['success']).to eq(true), -> { "Expected success but got error: #{result['error']}" }
      expect(result['result']).to eq(true)
    end
  end
end
