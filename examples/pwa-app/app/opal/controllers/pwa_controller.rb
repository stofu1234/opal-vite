# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class PwaController < StimulusController
  self.targets = %w[
    installPrompt
    swStatus
    installStatus
    lastUpdate
    noteInput
    notesList
    cacheCount
  ]

  def connect
    `
      const ctrl = this;
      ctrl.deferredPrompt = null;
      ctrl.notes = [];

      // Helper functions
      ctrl.checkInstallStatus = function() {
        if (!ctrl.hasInstallStatusTarget) return;

        if (window.matchMedia('(display-mode: standalone)').matches) {
          ctrl.installStatusTarget.textContent = 'Installed ✓';
          ctrl.installStatusTarget.className = 'status-value success';
        } else {
          ctrl.installStatusTarget.textContent = 'Not installed';
          ctrl.installStatusTarget.className = 'status-value';
        }
      };

      ctrl.updateLastUpdateTime = function() {
        if (!ctrl.hasLastUpdateTarget) return;
        const now = new Date();
        ctrl.lastUpdateTarget.textContent = now.toLocaleTimeString();
      };

      ctrl.checkServiceWorker = function() {
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
                    ctrl.updateLastUpdateTime();
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
      };

      ctrl.saveNotes = function() {
        try {
          localStorage.setItem('pwa-notes', JSON.stringify(ctrl.notes));
        } catch (e) {
          console.error('Error saving notes:', e);
        }
      };

      ctrl.renderNotes = function() {
        if (!ctrl.hasNotesListTarget) return;

        if (ctrl.notes.length === 0) {
          ctrl.notesListTarget.innerHTML = '<p class="empty-state">No notes yet. Add one above!</p>';
          return;
        }

        ctrl.notesListTarget.innerHTML = ctrl.notes.map(function(note) {
          const date = new Date(note.createdAt);
          const timeStr = date.toLocaleString();
          const syncIcon = note.synced ? '☁️' : '📱';

          return '<div class="note-item">' +
            '<div class="note-content">' +
              '<p class="note-text">' + note.text + '</p>' +
              '<small class="note-meta">' + syncIcon + ' ' + timeStr + '</small>' +
            '</div>' +
            '<button class="btn-delete" data-action="click->pwa#deleteNote" data-note-id="' + note.id + '">×</button>' +
          '</div>';
        }).join('');
      };

      ctrl.loadNotes = function() {
        try {
          const savedNotes = localStorage.getItem('pwa-notes');
          if (savedNotes) {
            ctrl.notes = JSON.parse(savedNotes);
            ctrl.renderNotes();
          }
        } catch (e) {
          console.error('Error loading notes:', e);
        }
      };

      ctrl.updateCacheCount = function() {
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
      };

      // Stimulus action methods
      this.install = function() {
        if (!ctrl.deferredPrompt) {
          alert('Installation prompt not available. Try using browser menu to install.');
          return;
        }

        ctrl.deferredPrompt.prompt();

        ctrl.deferredPrompt.userChoice.then(function(choiceResult) {
          if (choiceResult.outcome === 'accepted') {
            console.log('User accepted the install prompt');
          } else {
            console.log('User dismissed the install prompt');
          }
          ctrl.deferredPrompt = null;
          if (ctrl.hasInstallPromptTarget) {
            ctrl.installPromptTarget.style.display = 'none';
          }
        });
      };

      this.dismissInstallPrompt = function() {
        if (ctrl.hasInstallPromptTarget) {
          ctrl.installPromptTarget.style.display = 'none';
        }
      };

      this.addNote = function(event) {
        event.preventDefault();

        if (!ctrl.hasNoteInputTarget) return;

        const noteText = ctrl.noteInputTarget.value.trim();
        if (!noteText) return;

        const note = {
          id: Date.now(),
          text: noteText,
          createdAt: new Date().toISOString(),
          synced: navigator.onLine
        };

        ctrl.notes.unshift(note);
        ctrl.saveNotes();
        ctrl.renderNotes();

        ctrl.noteInputTarget.value = '';
      };

      this.deleteNote = function(event) {
        const noteId = parseInt(event.currentTarget.dataset.noteId);

        ctrl.notes = ctrl.notes.filter(function(note) {
          return note.id !== noteId;
        });

        ctrl.saveNotes();
        ctrl.renderNotes();
      };

      this.updateCache = function() {
        if ('serviceWorker' in navigator) {
          navigator.serviceWorker.getRegistration().then(function(registration) {
            if (registration) {
              registration.update().then(function() {
                ctrl.updateLastUpdateTime();
                alert('Cache updated! Refresh to see changes.');
              });
            }
          });
        }
      };

      this.clearCache = function() {
        if ('caches' in window) {
          caches.keys().then(function(names) {
            return Promise.all(
              names.map(function(name) {
                return caches.delete(name);
              })
            );
          }).then(function() {
            ctrl.updateCacheCount();
            alert('Cache cleared! Refresh to rebuild cache.');
          });
        }
      };

      // Listen for beforeinstallprompt event
      window.addEventListener('beforeinstallprompt', function(e) {
        e.preventDefault();
        ctrl.deferredPrompt = e;
        if (ctrl.hasInstallPromptTarget) {
          ctrl.installPromptTarget.style.display = 'block';
        }
      });

      // Listen for app installed event
      window.addEventListener('appinstalled', function() {
        if (ctrl.hasInstallPromptTarget) {
          ctrl.installPromptTarget.style.display = 'none';
        }
        if (ctrl.hasInstallStatusTarget) {
          ctrl.installStatusTarget.textContent = 'Installed ✓';
          ctrl.installStatusTarget.className = 'status-value success';
        }
      });

      // Initialize
      ctrl.checkInstallStatus();
      ctrl.checkServiceWorker();
      ctrl.loadNotes();
      ctrl.updateCacheCount();
    `
  end
end
