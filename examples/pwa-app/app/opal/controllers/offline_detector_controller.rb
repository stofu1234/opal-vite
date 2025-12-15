require 'opal_stimulus'

class OfflineDetectorController < StimulusController
  self.targets = %w[banner statusText onlineStatus]

  def connect
    `
      const ctrl = this;

      // Set initial status
      ctrl.updateStatus();

      // Listen for online/offline events
      window.addEventListener('online', function() {
        ctrl.updateStatus();
      });

      window.addEventListener('offline', function() {
        ctrl.updateStatus();
      });
    `
  end

  def update_status
    `
      const ctrl = this;
      const isOnline = navigator.onLine;

      if (ctrl.hasBannerTarget) {
        ctrl.bannerTarget.dataset.status = isOnline ? 'online' : 'offline';
      }

      if (ctrl.hasStatusTextTarget) {
        ctrl.statusTextTarget.textContent = isOnline ? '🟢 You are online' : '🔴 You are offline';
      }

      if (ctrl.hasOnlineStatusTarget) {
        ctrl.onlineStatusTarget.textContent = isOnline ? 'Online' : 'Offline';
        ctrl.onlineStatusTarget.className = isOnline ? 'status-value success' : 'status-value warning';
      }
    `
  end
end
