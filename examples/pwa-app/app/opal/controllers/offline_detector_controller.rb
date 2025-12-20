# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class OfflineDetectorController < StimulusController
  include StimulusHelpers

  self.targets = %w[banner statusText onlineStatus]

  def connect
    update_status
    setup_event_listeners
  end

  private

  def setup_event_listeners
    # Define update status method for event listeners
    js_define_method(:handleOnlineStatus) do
      update_status
    end

    on_window_event('online') { js_call(:handleOnlineStatus) }
    on_window_event('offline') { js_call(:handleOnlineStatus) }
  end

  def update_status
    is_online = `navigator.onLine`
    status = is_online ? 'online' : 'offline'

    # Set banner status attribute
    if has_target?(:banner)
      banner = get_target(:banner)
      dataset = js_get(banner, :dataset)
      js_set(dataset, :status, status)
    end

    # Set status text
    status_text = is_online ? '🟢 You are online' : '🔴 You are offline'
    target_set_text(:statusText, status_text)

    # Set online status indicator
    online_text = is_online ? 'Online' : 'Offline'
    online_class = is_online ? 'status-value success' : 'status-value warning'
    target_set_text(:onlineStatus, online_text)
    if has_target?(:onlineStatus)
      online_status_el = get_target(:onlineStatus)
      js_set(online_status_el, :className, online_class)
    end
  end
end
