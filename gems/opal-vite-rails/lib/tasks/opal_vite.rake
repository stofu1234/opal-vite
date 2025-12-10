namespace :opal_vite do
  desc "Compile Opal assets for production"
  task compile: :environment do
    require "opal/vite/rails"

    puts "Compiling Opal assets..."

    # Ensure Vite is installed
    unless system("which vite > /dev/null 2>&1")
      puts "Error: Vite is not installed. Run 'npm install' first."
      exit 1
    end

    # Run Vite build
    puts "Running Vite build..."
    system("npm run build") || system("npx vite build")

    puts "✅ Opal assets compiled successfully!"
  end

  desc "Clean compiled Opal assets"
  task clean: :environment do
    require "opal/vite/rails"

    puts "Cleaning Opal assets..."

    vite_dir = Rails.public_path.join("vite")
    if vite_dir.exist?
      FileUtils.rm_rf(vite_dir)
      puts "✅ Cleaned #{vite_dir}"
    else
      puts "No compiled assets found"
    end
  end

  desc "Show Opal-Vite configuration"
  task info: :environment do
    require "opal/vite/rails"

    puts "\n" + "="*60
    puts "Opal-Vite Rails Configuration"
    puts "="*60

    puts "\nOpal-Vite version: #{Opal::Vite::VERSION}"
    puts "Rails root: #{Rails.root}"
    puts "Vite manifest: #{Rails.public_path.join('vite', 'manifest.json')}"
    puts "Opal source directory: #{Rails.root.join('app', 'opal')}"

    if defined?(ViteRuby)
      puts "\nViteRuby: Installed ✅"
      puts "Vite dev server: #{ViteRuby.config.host}:#{ViteRuby.config.port}"
    else
      puts "\nViteRuby: Not installed ⚠️"
    end

    puts "\n" + "="*60
  end
end

# Add compile task to assets:precompile
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance do
    Rake::Task["opal_vite:compile"].invoke
  end
end
