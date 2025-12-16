# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class PwaController < StimulusController
  include StimulusHelpers

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
    deferred_prompt = js_prop(:deferredPrompt)
    unless deferred_prompt
      `alert('Installation prompt not available. Try using browser menu to install.')`
      return
    end

    js_call_on(deferred_prompt, :prompt)

    user_choice = js_get(deferred_prompt, :userChoice)
    js_then(user_choice) do |choice_result|
      outcome = js_get(choice_result, :outcome)
      if `#{outcome} === 'accepted'`
        console_log('User accepted the install prompt')
      else
        console_log('User dismissed the install prompt')
      end
    end

    js_set_prop(:deferredPrompt, nil)
    hide_target(:installPrompt) if has_target?(:installPrompt)
  end

  # Stimulus action: Dismiss install prompt
  def dismiss_install_prompt
    hide_target(:installPrompt) if has_target?(:installPrompt)
  end

  # Stimulus action: Add note
  def add_note(event)
    event.prevent_default

    return unless has_target?(:noteInput)

    note_text = target_value(:noteInput)
    note_text = `#{note_text}.trim()`
    return if `#{note_text} === ''`

    note = {
      id: js_timestamp,
      text: note_text,
      createdAt: js_iso_date,
      synced: `navigator.onLine`
    }

    @notes.unshift(note)
    save_notes
    render_notes

    target_set_value(:noteInput, '')
  end

  # Stimulus action: Delete note
  def delete_note(event)
    note_id = event_data_int('note-id')

    @notes.reject! { |note| note[:id] == note_id }

    save_notes
    render_notes
  end

  # Stimulus action: Update cache
  def update_cache
    return unless `'serviceWorker' in navigator`

    navigator = js_global('navigator')
    sw = js_get(navigator, :serviceWorker)
    promise = js_call_on(sw, :getRegistration)

    js_then(promise) do |registration|
      if registration
        update_promise = js_call_on(registration, :update)
        js_then(update_promise) do
          update_last_update_time
          `alert('Cache updated! Refresh to see changes.')`
        end
      end
    end
  end

  # Stimulus action: Clear cache
  def clear_cache
    return unless `'caches' in window`

    caches = js_global('caches')
    promise = js_call_on(caches, :keys)

    js_then(promise) do |names|
      delete_promises = js_map(names) do |name|
        js_call_on(caches, :delete, name)
      end

      all_promise = js_call_on(js_global('Promise'), :all, delete_promises)
      js_then(all_promise) do
        update_cache_count
        `alert('Cache cleared! Refresh to rebuild cache.')`
      end
    end
  end

  private

  def setup_install_listeners
    # Define install prompt handler
    js_define_method(:handleBeforeInstallPrompt) do |e|
      `#{e}.preventDefault()`
      js_set_prop(:deferredPrompt, e)
      set_target_style(:installPrompt, 'display', 'block') if has_target?(:installPrompt)
    end

    # Define app installed handler
    js_define_method(:handleAppInstalled) do
      hide_target(:installPrompt) if has_target?(:installPrompt)
      if has_target?(:installStatus)
        target_set_text(:installStatus, 'Installed ✓')
        set_install_status_class('status-value success')
      end
    end

    on_window_event('beforeinstallprompt') { |e| js_call(:handleBeforeInstallPrompt, e) }
    on_window_event('appinstalled') { js_call(:handleAppInstalled) }
  end

  def set_install_status_class(class_name)
    return unless has_target?(:installStatus)
    install_status = get_target(:installStatus)
    js_set(install_status, :className, class_name)
  end

  def check_install_status
    is_standalone = `window.matchMedia('(display-mode: standalone)').matches`

    if is_standalone
      target_set_text(:installStatus, 'Installed ✓')
      set_install_status_class('status-value success')
    else
      target_set_text(:installStatus, 'Not installed')
      set_install_status_class('status-value')
    end
  end

  def check_service_worker
    return unless has_target?(:swStatus)

    unless `'serviceWorker' in navigator`
      target_set_text(:swStatus, 'Not supported')
      set_sw_status_class('status-value error')
      return
    end

    # Define update handler
    js_define_method(:handleSwUpdate) do
      update_last_update_time
    end

    navigator = js_global('navigator')
    sw = js_get(navigator, :serviceWorker)
    promise = js_call_on(sw, :getRegistration)

    js_then(promise) do |registration|
      if registration
        target_set_text(:swStatus, 'Active ✓')
        set_sw_status_class('status-value success')

        # Listen for updates
        on_element_event(registration, 'updatefound') do
          new_worker = js_get(registration, :installing)
          on_element_event(new_worker, 'statechange') do
            state = js_get(new_worker, :state)
            js_call(:handleSwUpdate) if `#{state} === 'activated'`
          end
        end
      else
        target_set_text(:swStatus, 'Not registered')
        set_sw_status_class('status-value warning')
      end
    end
  end

  def set_sw_status_class(class_name)
    return unless has_target?(:swStatus)
    sw_status = get_target(:swStatus)
    js_set(sw_status, :className, class_name)
  end

  def load_notes
    js_data = storage_get_json(NOTES_KEY)
    return unless js_data

    begin
      @notes = []
      js_each(js_data) do |item|
        @notes << {
          id: js_get(item, :id),
          text: js_get(item, :text),
          createdAt: js_get(item, :createdAt),
          synced: js_get(item, :synced)
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
    storage_set_json(NOTES_KEY, js_array)
  rescue => e
    puts "Error saving notes: #{e}"
  end

  def render_notes
    return unless has_target?(:notesList)

    if @notes.empty?
      target_set_html(:notesList, '<p class="empty-state">No notes yet. Add one above!</p>')
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

    target_set_html(:notesList, html)
  end

  def update_last_update_time
    target_set_text(:lastUpdate, `new Date().toLocaleTimeString()`)
  end

  def update_cache_count
    return unless has_target?(:cacheCount)

    unless `'caches' in window`
      target_set_text(:cacheCount, 'N/A')
      return
    end

    # Define cache count handler
    js_define_method(:updateCacheCountValue) do |count|
      target_set_text(:cacheCount, count.to_s)
    end

    caches = js_global('caches')
    promise = js_call_on(caches, :keys)

    js_then(promise) do |names|
      js_set_prop(:totalEntries, 0)

      promises = js_map(names) do |name|
        open_promise = js_call_on(caches, :open, name)
        js_then(open_promise) do |cache|
          keys_promise = js_call_on(cache, :keys)
          js_then(keys_promise) do |keys|
            current = js_prop(:totalEntries) || 0
            js_set_prop(:totalEntries, current + js_length(keys))
          end
        end
      end

      all_promise = js_call_on(js_global('Promise'), :all, promises)
      js_then(all_promise) do
        js_call(:updateCacheCountValue, js_prop(:totalEntries))
      end
    end
  end
end
