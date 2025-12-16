# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class PwaController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers
  include Storable

  self.targets = %w[
    installPrompt
    swStatus
    installStatus
    lastUpdate
    noteInput
    notesList
    cacheCount
  ]

  NOTES_KEY = 'pwa-notes'

  def initialize
    super
    @deferred_prompt = nil
    @notes = []
  end

  def connect
    puts 'PwaController connected!'
    setup_install_listeners
    check_install_status
    check_service_worker
    load_notes
    update_cache_count
  end

  # Stimulus action: Install PWA
  def install
    unless @deferred_prompt
      `alert('Installation prompt not available. Try using browser menu to install.')`
      return
    end

    `#{@deferred_prompt}.prompt()`

    `#{@deferred_prompt}.userChoice.then(function(choiceResult) {
      if (choiceResult.outcome === 'accepted') {
        console.log('User accepted the install prompt');
      } else {
        console.log('User dismissed the install prompt');
      }
    })`

    @deferred_prompt = nil
    `
      if (this.hasInstallPromptTarget) {
        this.installPromptTarget.style.display = 'none';
      }
    `
  end

  # Stimulus action: Dismiss install prompt
  def dismiss_install_prompt
    `
      if (this.hasInstallPromptTarget) {
        this.installPromptTarget.style.display = 'none';
      }
    `
  end

  # Stimulus action: Add note
  def add_note(event)
    event.prevent_default

    return unless `this.hasNoteInputTarget`

    note_text = `this.noteInputTarget.value.trim()`
    return if note_text.nil? || note_text.empty?

    note = {
      id: `Date.now()`,
      text: note_text,
      createdAt: `new Date().toISOString()`,
      synced: `navigator.onLine`
    }

    @notes.unshift(note)
    save_notes
    render_notes

    `this.noteInputTarget.value = ''`
  end

  # Stimulus action: Delete note
  def delete_note(event)
    note_id = wrap_js(event.current_target.dataset)[:note_id].to_i

    @notes.reject! { |note| note[:id] == note_id }

    save_notes
    render_notes
  end

  # Stimulus action: Update cache
  def update_cache
    `
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistration().then(function(registration) {
          if (registration) {
            registration.update().then(function() {
              #{update_last_update_time}
              alert('Cache updated! Refresh to see changes.');
            });
          }
        });
      }
    `
  end

  # Stimulus action: Clear cache
  def clear_cache
    `
      if ('caches' in window) {
        caches.keys().then(function(names) {
          return Promise.all(
            names.map(function(name) {
              return caches.delete(name);
            })
          );
        }).then(function() {
          #{update_cache_count}
          alert('Cache cleared! Refresh to rebuild cache.');
        });
      }
    `
  end

  private

  def setup_install_listeners
    `
      const ctrl = this;

      // Listen for beforeinstallprompt event
      window.addEventListener('beforeinstallprompt', function(e) {
        e.preventDefault();
        ctrl.deferred_prompt = e;
        if (ctrl.$has_install_prompt_target()) {
          ctrl.$install_prompt_target().style.display = 'block';
        }
      });

      // Listen for app installed event
      window.addEventListener('appinstalled', function() {
        if (ctrl.$has_install_prompt_target()) {
          ctrl.$install_prompt_target().style.display = 'none';
        }
        if (ctrl.$has_install_status_target()) {
          ctrl.$install_status_target().textContent = 'Installed ✓';
          ctrl.$install_status_target().className = 'status-value success';
        }
      });
    `
  end

  def check_install_status
    is_standalone = `window.matchMedia('(display-mode: standalone)').matches`

    if is_standalone
      set_target_text(:install_status, 'Installed ✓')
      set_target_class(:install_status, 'status-value success')
    else
      set_target_text(:install_status, 'Not installed')
      set_target_class(:install_status, 'status-value')
    end
  end

  def check_service_worker
    `
      const ctrl = this;

      if (!ctrl.hasSwStatusTarget) return;

      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistration().then(function(registration) {
          if (registration) {
            ctrl.swStatusTarget.textContent = 'Active ✓';
            ctrl.swStatusTarget.className = 'status-value success';

            // Listen for updates
            registration.addEventListener('updatefound', function() {
              const newWorker = registration.installing;
              newWorker.addEventListener('statechange', function() {
                if (newWorker.state === 'activated') {
                  ctrl.$update_last_update_time();
                }
              });
            });
          } else {
            ctrl.swStatusTarget.textContent = 'Not registered';
            ctrl.swStatusTarget.className = 'status-value warning';
          }
        });
      } else {
        ctrl.swStatusTarget.textContent = 'Not supported';
        ctrl.swStatusTarget.className = 'status-value error';
      }
    `
  end

  def load_notes
    js_data = storage_get(NOTES_KEY)
    return unless js_data

    begin
      @notes = []
      length = `#{js_data}.length`
      length.times do |i|
        item = `#{js_data}[#{i}]`
        @notes << {
          id: `#{item}.id`,
          text: `#{item}.text`,
          createdAt: `#{item}.createdAt`,
          synced: `#{item}.synced`
        }
      end
      render_notes
    rescue => e
      puts "Error loading notes: #{e}"
    end
  end

  def save_notes
    js_array = `[]`
    @notes.each do |note|
      `#{js_array}.push({
        id: #{note[:id]},
        text: #{note[:text]},
        createdAt: #{note[:createdAt]},
        synced: #{note[:synced]}
      })`
    end
    storage_set(NOTES_KEY, `#{js_array}`)
  rescue => e
    puts "Error saving notes: #{e}"
  end

  def render_notes
    return unless `this.hasNotesListTarget`

    if @notes.empty?
      `this.notesListTarget.innerHTML = '<p class="empty-state">No notes yet. Add one above!</p>'`
      return
    end

    html = @notes.map do |note|
      time_str = `new Date(#{note[:createdAt]}).toLocaleString()`
      sync_icon = note[:synced] ? '☁️' : '📱'

      "<div class=\"note-item\">" \
        "<div class=\"note-content\">" \
          "<p class=\"note-text\">#{note[:text]}</p>" \
          "<small class=\"note-meta\">#{sync_icon} #{time_str}</small>" \
        "</div>" \
        "<button class=\"btn-delete\" data-action=\"click->pwa#delete_note\" data-note-id=\"#{note[:id]}\">×</button>" \
      "</div>"
    end.join

    `this.notesListTarget.innerHTML = #{html}`
  end

  def update_last_update_time
    set_target_text(:last_update, `new Date().toLocaleTimeString()`)
  end

  def update_cache_count
    `
      const ctrl = this;

      if (!ctrl.hasCacheCountTarget) return;

      if ('caches' in window) {
        caches.keys().then(function(names) {
          let totalEntries = 0;
          const promises = names.map(function(name) {
            return caches.open(name).then(function(cache) {
              return cache.keys().then(function(keys) {
                totalEntries += keys.length;
              });
            });
          });

          Promise.all(promises).then(function() {
            ctrl.cacheCountTarget.textContent = totalEntries;
          });
        });
      } else {
        ctrl.cacheCountTarget.textContent = 'N/A';
      }
    `
  end
end
