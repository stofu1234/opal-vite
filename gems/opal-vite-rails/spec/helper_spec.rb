require "spec_helper"

RSpec.describe Opal::Vite::Rails::Helper do
  let(:view) do
    Class.new do
      include ActionView::Helpers::OutputSafetyHelper
      include Opal::Vite::Rails::Helper

      def vite_javascript_tag(name, **options)
        "<script #{name} #{options}>".html_safe
      end
    end.new
  end

  describe "#opal_javascript_tag" do
    it "appends .js to an entrypoint name" do
      expect(view.opal_javascript_tag("application")).to include("application.js ")
    end

    it "does not double the extension" do
      tag = view.opal_javascript_tag("application.js")
      expect(tag).to include("application.js ")
      expect(tag).not_to include("application.js.js")
    end

    it "accepts a symbol and nested paths" do
      expect(view.opal_javascript_tag(:application)).to include("application.js ")
      expect(view.opal_javascript_tag("components/widget")).to include("components/widget.js ")
    end

    it "passes options through" do
      expect(view.opal_javascript_tag("application", defer: true)).to include("defer")
    end
  end

  describe "#opal_runtime_tag" do
    around do |example|
      deprecator = Opal::Vite::Rails.deprecator
      previous = deprecator.behavior
      deprecator.behavior = :silence
      example.run
      deprecator.behavior = previous
    end

    it "outputs nothing" do
      expect(view.opal_runtime_tag).to eq("")
    end

    it "warns through the shared deprecator" do
      expect(Opal::Vite::Rails.deprecator).to receive(:warn).with(/opal_runtime_tag/)
      view.opal_runtime_tag
    end
  end
end
