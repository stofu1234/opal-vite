module Opal
  module Vite
    module Rails
      module Helper
        # Generate script tag for an entrypoint that loads Opal code
        #
        # Usage in views:
        #   <%= opal_javascript_tag "application" %>
        #
        # Delegates to vite_javascript_tag in every environment: Vite emits ES
        # modules, so the tag must carry type="module" (plus crossorigin and
        # modulepreload links), and vite_ruby already switches between the dev
        # server and the build manifest.
        def opal_javascript_tag(name, **options)
          vite_javascript_tag("#{name}.js", **options)
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
        #
        # NOTE: the manifest lives on the ViteRuby *instance* — `ViteRuby.manifest`
        # is not a class-level delegator (it raises NoMethodError), so we go
        # through `ViteRuby.instance`. Use ViteRuby::Manifest#path_for (public)
        # rather than #lookup: #lookup is *protected* and returns the raw manifest
        # entry Hash ({ "file" => "..." }), so `lookup(name).to_s` would emit the
        # Hash's inspect string instead of a URL. #path_for returns the resolved
        # asset URL string.
        def opal_asset_path(name)
          if defined?(ViteRuby)
            ViteRuby.instance.manifest.path_for(name)
          else
            # Fallback to standard asset path
            "/#{Opal::Vite::Rails.config.public_output_path}/#{name}"
          end
        end

        # Deprecated: outputs nothing.
        #
        # Compiled .rb modules import the Opal runtime (`/@opal-runtime`)
        # themselves, and in production it is bundled into the entrypoint's
        # chunks, so there is no separate runtime file to load. A standalone
        # tag would load a second copy of the runtime in development.
        def opal_runtime_tag(**_options)
          ActiveSupport::Deprecation.new("0.4", "opal-vite-rails").warn(
            "opal_runtime_tag is no longer needed and outputs nothing; remove it from your views."
          )
          "".html_safe
        end
      end
    end
  end
end
