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

        end

        # app/* subdirectories are Zeitwerk roots, so without this the Opal
        # sources (browser code) would be eager loaded by MRI in production
        # and fail with LoadError on `require 'native'` etc.
        initializer "opal_vite.ignore_opal_sources" do |app|
          opal_dirs = [
            ::Rails.root.join(app.config.opal_vite.source_path || Opal::Vite::Rails.config.source_path)
          ]
          if defined?(ViteRuby)
            opal_dirs << ViteRuby.config.root.join(ViteRuby.config.source_code_dir, "opal")
          end

          ::Rails.autoloaders.each do |autoloader|
            opal_dirs.uniq.each { |dir| autoloader.ignore(dir) }
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
