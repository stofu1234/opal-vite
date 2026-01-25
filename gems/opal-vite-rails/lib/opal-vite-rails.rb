require "ostruct"
require "opal-vite"
require "rails"
require "vite_rails"

require_relative "opal/vite/rails/version"
require_relative "opal/vite/rails/engine"
require_relative "opal/vite/rails/helper"
require_relative "opal/vite/rails/manifest"

module Opal
  module Vite
    module Rails
      class Error < StandardError; end

      class << self
        attr_accessor :config

        def configure
          yield(config) if block_given?
        end
      end

      @config = OpenStruct.new(
        # Default configuration
        source_path: "app/opal",
        public_output_path: "vite-opal",
        manifest_path: nil # Will be set by ViteRails
      )
    end
  end
end
