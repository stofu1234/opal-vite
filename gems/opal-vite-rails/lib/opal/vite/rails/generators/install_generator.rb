require "rails/generators/base"
require "json"
require "pathname"

module Opal
  module Vite
    module Rails
      module Generators
        class InstallGenerator < ::Rails::Generators::Base
          source_root File.expand_path("../../../../../templates", __dir__)

          namespace "opal_vite:install"

          desc "Install Opal-Vite in your Rails application"

          def check_vite_rails
            unless defined?(ViteRuby)
              say "ViteRails is not installed. Installing it first...", :yellow
              run "bundle add vite_rails"
              run "bundle exec vite install"
            end
          end

          # Opal sources live under vite_ruby's sourceCodeDir so that the Vite
          # dev server and autoBuild watch them like any other frontend file.
          def create_application_rb
            template "application.rb.tt", File.join(opal_dir, "application.rb")
          end

          # An entrypoint is what puts the Ruby code into a Vite bundle; without
          # it application.rb is never compiled.
          def create_entrypoint
            template "opal_entrypoint.js.tt", File.join(entrypoints_dir, "opal.js")
          end

          def create_vite_config
            if File.exist?(File.join(destination_root, "vite.config.ts"))
              inject_into_file "vite.config.ts", after: "import { defineConfig } from 'vite'\n" do
                "import opal from 'vite-plugin-opal'\n"
              end

              inject_into_file "vite.config.ts", after: "plugins: [\n" do
                "    opal({\n" \
                "      loadPaths: ['./#{opal_dir}'],\n" \
                "      sourceMap: true\n" \
                "    }),\n"
              end
            else
              template "vite.config.ts.tt", "vite.config.ts"
            end
          end

          def create_package_json_entry
            if File.exist?("package.json")
              say "Adding vite-plugin-opal to package.json...", :green
              say "Run: npm install vite-plugin-opal", :yellow
            end
          end

          def create_example_view
            create_file "app/views/opal_demo/index.html.erb", <<~ERB
              <h1>Opal + Vite + Rails Demo</h1>

              <div id="opal-content">
                <p>Check your browser console to see Opal output!</p>
              </div>

              <%= opal_javascript_tag "opal" %>
            ERB
          end

          def add_route
            route "get '/opal_demo', to: 'opal_demo#index'"
          end

          def create_controller
            create_file "app/controllers/opal_demo_controller.rb", <<~RUBY
              class OpalDemoController < ApplicationController
                def index
                end
              end
            RUBY
          end

          def show_post_install_message
            say "\n" + "="*60, :green
            say "Opal-Vite installed successfully!", :green
            say "="*60, :green
            say "\nNext steps:", :yellow
            say "  1. Install JavaScript dependencies:", :cyan
            say "     npm install vite-plugin-opal"
            say "\n  2. Start Vite dev server:", :cyan
            say "     bin/vite dev"
            say "\n  3. Start Rails server:", :cyan
            say "     rails server"
            say "\n  4. Visit:", :cyan
            say "     http://localhost:3000/opal_demo"
            say "\n" + "="*60, :green
          end

          private

          def source_code_dir
            vite_config_value(:source_code_dir, "sourceCodeDir", "app/frontend")
          end

          def entrypoints_dir
            File.join(source_code_dir, vite_config_value(:entrypoints_dir, "entrypointsDir", "entrypoints"))
          end

          def opal_dir
            File.join(source_code_dir, "opal")
          end

          # Path of application.rb as imported from the entrypoint
          def opal_import_path
            path = Pathname.new(File.join(opal_dir, "application.rb"))
              .relative_path_from(Pathname.new(entrypoints_dir)).to_s
            path.start_with?(".") ? path : "./#{path}"
          end

          # Read a vite_ruby setting, falling back to config/vite.json (vite_rails
          # may have been installed by this generator in a separate process) and
          # then to vite_ruby's default.
          def vite_config_value(method, json_key, default)
            return ViteRuby.config.public_send(method).to_s if defined?(ViteRuby)

            vite_json.dig("all", json_key) || default
          end

          def vite_json
            @vite_json ||= begin
              path = File.join(destination_root, "config", "vite.json")
              File.exist?(path) ? JSON.parse(File.read(path)) : {}
            end
          end
        end
      end
    end
  end
end
