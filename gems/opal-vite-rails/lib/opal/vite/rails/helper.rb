module Opal
  module Vite
    module Rails
      module Helper
        # Generate script tag for Opal JavaScript
        #
        # Usage in views:
        #   <%= opal_javascript_tag "application" %>
        #
        def opal_javascript_tag(name, **options)
          if vite_running?
            # Development: load from Vite dev server
            vite_javascript_tag("#{name}.js", **options)
          else
            # Production: load from manifest
            asset_path = opal_asset_path("#{name}.js")
            javascript_include_tag(asset_path, **options)
          end
        end

        # Generate multiple script tags for Opal JavaScript files
        #
        # Usage:
        #   <%= opal_javascript_tags "application", "components/widget" %>
        #
        def opal_javascript_tags(*names, **options)
          safe_join(names.map { |name| opal_javascript_tag(name, **options) }, "\n")
        end

        # Check if Vite dev server is running
        def vite_running?
          defined?(ViteRuby) && ViteRuby.instance.dev_server_running?
        end

        # Get asset path from Vite manifest
        def opal_asset_path(name)
          if defined?(ViteRuby)
            ViteRuby.manifest.lookup(name).to_s
          else
            # Fallback to standard asset path
            "/#{Opal::Vite::Rails.config.public_output_path}/#{name}"
          end
        end

        # Include Opal runtime
        # This is automatically included when using opal_javascript_tag,
        # but can be called explicitly if needed
        def opal_runtime_tag(**options)
          if vite_running?
            vite_javascript_tag("@opal-runtime", **options)
          else
            asset_path = opal_asset_path("opal-runtime.js")
            javascript_include_tag(asset_path, **options)
          end
        end
      end
    end
  end
end
