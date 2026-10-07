namespace :opal_vite do
  # Opal sources are compiled by the Vite build (vite-plugin-opal), so this
  # delegates to vite_ruby, the same build `rake vite:build` runs. vite_rails
  # already hooks that build into `assets:precompile`, so nothing is added
  # there.
  desc "Compile Opal assets for production (runs the Vite build)"
  task compile: :environment do
    puts "Compiling Opal assets..."

    abort "❌ Vite build failed" unless ViteRuby.commands.build

    puts "✅ Opal assets compiled successfully!"
  end

  desc "Clean compiled Opal assets"
  task clean: :environment do
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
