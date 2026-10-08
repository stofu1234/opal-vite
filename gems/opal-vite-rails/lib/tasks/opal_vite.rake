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

  desc "Clean compiled Opal assets (the Vite build output of the current RAILS_ENV)"
  task clean: :environment do
    puts "Cleaning Opal assets..."

    # The directory vite_ruby builds into for this environment (config/vite.json
    # publicOutputDir), e.g. public/vite-dev in development and public/vite in
    # production. A build you commit (public/vite) is only removed when this
    # runs with RAILS_ENV=production.
    vite = ViteRuby.config
    vite_dir = vite.build_output_dir.expand_path
    # Only ever delete a subdirectory of the public dir, so a misconfigured
    # publicOutputDir ("", ".", "..") cannot wipe public/ or the app itself.
    public_dir = vite.root.join(vite.public_dir).expand_path
    unless vite_dir.to_s.start_with?("#{public_dir}#{File::SEPARATOR}")
      abort "❌ Refusing to delete #{vite_dir}: it is not inside #{public_dir}"
    end

    if vite_dir.exist?
      FileUtils.rm_rf(vite_dir)
      puts "✅ Cleaned #{vite_dir}"
    else
      puts "No compiled assets found in #{vite_dir}"
    end
  end

  desc "Show Opal-Vite configuration"
  task info: :environment do
    puts "\n" + "="*60
    puts "Opal-Vite Rails Configuration"
    puts "="*60

    puts "\nOpal-Vite version: #{Opal::Vite::VERSION}"
    puts "Rails root: #{Rails.root}"

    vite = ViteRuby.config
    manifest = vite.manifest_paths.first
    puts "Vite build output: #{vite.build_output_dir}"
    puts "Vite manifest: #{manifest || vite.known_manifest_paths.first} (#{manifest ? 'found' : 'not built yet'})"
    puts "Opal source directory: #{Rails.root.join(Opal::Vite::Rails.config.source_path)}"
    puts "Vite source directory: #{vite.root.join(vite.source_code_dir)}"
    puts "Vite dev server: #{vite.host}:#{vite.port}"

    puts "\n" + "="*60
  end
end
