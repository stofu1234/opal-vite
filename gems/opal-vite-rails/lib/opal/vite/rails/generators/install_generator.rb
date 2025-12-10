require "rails/generators/base"

module Opal
  module Vite
    module Rails
      module Generators
        class InstallGenerator < ::Rails::Generators::Base
          source_root File.expand_path("../../../../../templates", __dir__)

          desc "Install Opal-Vite in your Rails application"

          def check_vite_rails
            unless defined?(ViteRuby)
              say "ViteRails is not installed. Installing it first...", :yellow
              run "bundle add vite_rails"
              run "bundle exec vite install"
            end
          end

          def create_opal_directory
            empty_directory "app/opal"
            create_file "app/opal/.keep"
          end

          def create_application_rb
            template "application.rb.tt", "app/opal/application.rb"
          end

          def create_vite_config
            if File.exist?("vite.config.ts")
              inject_into_file "vite.config.ts", after: "import { defineConfig } from 'vite'\n" do
                "import opal from 'vite-plugin-opal'\n"
              end

              inject_into_file "vite.config.ts", after: "plugins: [\n" do
                "    opal({\n" \
                "      loadPaths: ['./app/opal'],\n" \
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

              <%= opal_javascript_tag "application" %>
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
        end
      end
    end
  end
end
