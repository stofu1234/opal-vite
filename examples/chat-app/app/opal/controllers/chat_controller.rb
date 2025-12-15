# backtick_javascript: true

# Chat controller demonstrating WebSocket integration
class ChatController < StimulusController
  self.targets = ["messages", "input", "userCount", "typingIndicator", "usernameInput", "chatContainer", "loginContainer"]
  self.values = { username: :string }

  def connect
    puts "Chat controller connected!"

    # Set up WebSocket connection and helper methods
    `
      const ctrl = this;
      let typingTimeout = null;

      // WebSocket connection
      this.ws = null;
      this.isConnected = false;

      // Connect to WebSocket server
      this.connectWebSocket = function() {
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = protocol + '//' + window.location.hostname + ':3007';

        ctrl.ws = new WebSocket(wsUrl);

        ctrl.ws.onopen = function() {
          console.log('✅ Connected to WebSocket server');
          ctrl.isConnected = true;

          // Send join message if username is set
          if (ctrl.usernameValue) {
            ctrl.ws.send(JSON.stringify({
              type: 'join',
              username: ctrl.usernameValue
            }));
          }
        };

        ctrl.ws.onmessage = function(event) {
          const message = JSON.parse(event.data);
          ctrl.handleMessage(message);
        };

        ctrl.ws.onclose = function() {
          console.log('❌ Disconnected from WebSocket server');
          ctrl.isConnected = false;

          // Attempt to reconnect after 3 seconds
          setTimeout(function() {
            console.log('🔄 Attempting to reconnect...');
            ctrl.connectWebSocket();
          }, 3000);
        };

        ctrl.ws.onerror = function(error) {
          console.error('WebSocket error:', error);
        };
      };

      // Handle incoming messages
      this.handleMessage = function(message) {
        switch (message.type) {
          case 'history':
            ctrl.loadHistory(message.messages);
            break;
          case 'message':
            ctrl.addMessage(message);
            break;
          case 'system':
            ctrl.addSystemMessage(message);
            break;
          case 'user_count':
            ctrl.updateUserCount(message.count);
            break;
          case 'typing':
            ctrl.updateTypingIndicator(message);
            break;
        }
      };

      // Load message history
      this.loadHistory = function(messages) {
        messages.forEach(function(msg) {
          if (msg.type === 'message') {
            ctrl.addMessage(msg, false);
          } else if (msg.type === 'system') {
            ctrl.addSystemMessage(msg, false);
          }
        });
      };

      // Add chat message to UI
      this.addMessage = function(message, scroll = true) {
        const messageEl = document.createElement('div');
        messageEl.className = 'message';

        const isOwnMessage = message.username === ctrl.usernameValue;
        if (isOwnMessage) {
          messageEl.classList.add('own-message');
        }

        const time = new Date(message.timestamp).toLocaleTimeString();

        messageEl.innerHTML = '<div class="message-header">' +
          '<span class="message-username">' + message.username + '</span>' +
          '<span class="message-time">' + time + '</span>' +
        '</div>' +
        '<div class="message-text">' + ctrl.escapeHtml(message.text) + '</div>';

        ctrl.messagesTarget.appendChild(messageEl);

        if (scroll) {
          ctrl.scrollToBottom();
        }
      };

      // Add system message
      this.addSystemMessage = function(message, scroll = true) {
        const messageEl = document.createElement('div');
        messageEl.className = 'system-message';
        messageEl.textContent = message.text;

        ctrl.messagesTarget.appendChild(messageEl);

        if (scroll) {
          ctrl.scrollToBottom();
        }
      };

      // Update user count
      this.updateUserCount = function(count) {
        if (ctrl.hasUserCountTarget) {
          ctrl.userCountTarget.textContent = count + ' user' + (count !== 1 ? 's' : '') + ' online';
        }
      };

      // Update typing indicator
      this.updateTypingIndicator = function(message) {
        if (!ctrl.hasTypingIndicatorTarget) return;

        if (message.isTyping) {
          ctrl.typingIndicatorTarget.textContent = message.username + ' is typing...';
          ctrl.typingIndicatorTarget.style.display = 'block';
        } else {
          ctrl.typingIndicatorTarget.style.display = 'none';
        }
      };

      // Scroll chat to bottom
      this.scrollToBottom = function() {
        ctrl.messagesTarget.scrollTop = ctrl.messagesTarget.scrollHeight;
      };

      // Escape HTML to prevent XSS
      this.escapeHtml = function(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
      };

      // Connect to WebSocket
      ctrl.connectWebSocket();
    `
  end

  # Send message
  def send_message
    `
      const text = this.inputTarget.value.trim();

      if (!text || !this.isConnected) {
        return;
      }

      // Send message to server
      this.ws.send(JSON.stringify({
        type: 'message',
        text: text
      }));

      // Clear input
      this.inputTarget.value = '';

      // Send typing stopped
      this.ws.send(JSON.stringify({
        type: 'typing',
        isTyping: false
      }));
    `
  end

  # Handle input keypress
  def handle_keypress
    `
      // Send message on Enter key
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        this.$send_message();
        return;
      }

      // Send typing indicator
      if (this.isConnected) {
        this.ws.send(JSON.stringify({
          type: 'typing',
          isTyping: true
        }));

        // Clear previous timeout
        if (typingTimeout) {
          clearTimeout(typingTimeout);
        }

        // Set timeout to send typing stopped
        typingTimeout = setTimeout(() => {
          this.ws.send(JSON.stringify({
            type: 'typing',
            isTyping: false
          }));
        }, 1000);
      }
    `
  end

  # Join chat with username
  def join_chat
    `
      const username = this.usernameInputTarget.value.trim();

      if (!username) {
        alert('Please enter a username');
        return;
      }

      // Set username value
      this.usernameValue = username;

      // Send join message if connected
      if (this.isConnected) {
        this.ws.send(JSON.stringify({
          type: 'join',
          username: username
        }));
      }

      // Hide login, show chat
      this.loginContainerTarget.style.display = 'none';
      this.chatContainerTarget.style.display = 'flex';

      // Focus on input
      this.inputTarget.focus();
    `
  end

  # Handle username input keypress
  def handle_username_keypress
    `
      if (event.key === 'Enter') {
        event.preventDefault();
        this.$join_chat();
      }
    `
  end
end
