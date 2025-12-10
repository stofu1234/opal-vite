require "rails/engine"

module Opal
  module Vite
    module Rails
      class Engine < ::Rails::Engine
        isolate_namespace Opal::Vite::Rails

        config.opal_vite = ActiveSupport::OrderedOptions.new

        initializer "opal_vite.set_configs" do |app|
          # Set default configuration from app config
          if app.config.opal_vite.source_path
            Opal::Vite::Rails.config.source_path = app.config.opal_vite.source_path
          end

          if app.config.opal_vite.public_output_path
            Opal::Vite::Rails.config.public_output_path = app.config.opal_vite.public_output_path
          end

          # Set manifest path from ViteRails
          if defined?(ViteRuby)
            Opal::Vite::Rails.config.manifest_path = ViteRuby.manifest_path
          end
        end

        initializer "opal_vite.view_helpers" do
          ActiveSupport.on_load(:action_view) do
            include Opal::Vite::Rails::Helper
          end
        end

        initializer "opal_vite.assets" do |app|
          # Add Opal source path to asset paths
          if app.config.respond_to?(:assets)
            app.config.assets.paths << ::Rails.root.join(Opal::Vite::Rails.config.source_path)
          end
        end

        rake_tasks do
          load "tasks/opal_vite.rake"
        end

        generators do
          require_relative "generators/install_generator"
        end
      end
    end
  end
end
