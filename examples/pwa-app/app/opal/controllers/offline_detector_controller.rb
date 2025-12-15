# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class OfflineDetectorController < StimulusController
  include JsProxyEx
  include DomHelpers

  self.targets = %w[banner statusText onlineStatus]

  def connect
    update_status
    setup_event_listeners
  end

  private

  def setup_event_listeners
    `
      const ctrl = this;
      window.addEventListener('online', function() { ctrl.$update_status(); });
      window.addEventListener('offline', function() { ctrl.$update_status(); });
    `
  end

  def update_status
    is_online = `navigator.onLine`
    status = is_online ? 'online' : 'offline'

    # Set banner status attribute
    `
      if (this.hasBannerTarget) {
        this.bannerTarget.dataset.status = #{status};
      }
    `

    # Set status text
    status_text = is_online ? '🟢 You are online' : '🔴 You are offline'
    set_target_text(:status_text, status_text)

    # Set online status indicator
    online_text = is_online ? 'Online' : 'Offline'
    online_class = is_online ? 'status-value success' : 'status-value warning'
    set_target_text(:online_status, online_text)
    set_target_class(:online_status, online_class)
  end
end
