# backtick_javascript: true

# Chat controller demonstrating WebSocket integration
class ChatController < StimulusController
  include StimulusHelpers

  self.targets = ["messages", "input", "userCount", "typingIndicator", "usernameInput", "chatContainer", "loginContainer"]
  self.values = { username: :string }

  def connect
    puts "Chat controller connected!"
    setup_websocket
  end

  # Send message
  def send_message
    text = target_value(:input)
    text = `#{text}.trim()`

    return if `#{text} === '' || !this.isConnected`

    # Send message to server
    `
      this.ws.send(JSON.stringify({
        type: 'message',
        text: #{text}
      }));
    `

    target_set_value(:input, '')

    # Send typing stopped
    `
      this.ws.send(JSON.stringify({
        type: 'typing',
        isTyping: false
      }));
    `
  end

  # Handle input keypress
  def handle_keypress
    if event_key == 'Enter' && !`event.shiftKey`
      prevent_default
      send_message
      return
    end

    # Send typing indicator
    `
      if (this.isConnected) {
        this.ws.send(JSON.stringify({
          type: 'typing',
          isTyping: true
        }));

        if (this.typingTimeout) clearTimeout(this.typingTimeout);

        this.typingTimeout = setTimeout(() => {
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
    username = target_value(:usernameInput)
    username = `#{username}.trim()`

    if `#{username} === ''`
      `alert('Please enter a username')`
      return
    end

    # Set username value
    `this.usernameValue = #{username}`

    # Send join message if connected
    `
      if (this.isConnected) {
        this.ws.send(JSON.stringify({
          type: 'join',
          username: #{username}
        }));
      }
    `

    # Hide login, show chat
    hide_target(:loginContainer) if has_target?(:loginContainer)
    set_target_style(:chatContainer, 'display', 'flex') if has_target?(:chatContainer)

    target_focus(:input)
  end

  # Handle username input keypress
  def handle_username_keypress
    if event_key == 'Enter'
      prevent_default
      join_chat
    end
  end

  private

  def setup_websocket
    `
      const ctrl = this;
      this.ws = null;
      this.isConnected = false;
      this.typingTimeout = null;

      this.connectWebSocket = function() {
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = protocol + '//' + window.location.hostname + ':3007';
        ctrl.ws = new WebSocket(wsUrl);

        ctrl.ws.onopen = function() {
          console.log('✅ Connected to WebSocket server');
          ctrl.isConnected = true;
          if (ctrl.usernameValue) {
            ctrl.ws.send(JSON.stringify({ type: 'join', username: ctrl.usernameValue }));
          }
        };

        ctrl.ws.onmessage = function(event) {
          ctrl.$handle_message(JSON.parse(event.data));
        };

        ctrl.ws.onclose = function() {
          console.log('❌ Disconnected from WebSocket server');
          ctrl.isConnected = false;
          setTimeout(() => {
            console.log('🔄 Attempting to reconnect...');
            ctrl.connectWebSocket();
          }, 3000);
        };

        ctrl.ws.onerror = function(error) {
          console.error('WebSocket error:', error);
        };
      };

      ctrl.connectWebSocket();
    `
  end

  def handle_message(message)
    type = `#{message}.type`

    case type
    when 'history'
      load_history(`#{message}.messages`)
    when 'message'
      add_message(message)
    when 'system'
      add_system_message(message)
    when 'user_count'
      update_user_count(`#{message}.count`)
    when 'typing'
      update_typing_indicator(message)
    end
  end

  def load_history(messages)
    length = `#{messages}.length`
    `for (var i = 0; i < #{length}; i++) {`
      msg = `#{messages}[i]`
      msg_type = `#{msg}.type`

      if msg_type == 'message'
        add_message(msg, false)
      elsif msg_type == 'system'
        add_system_message(msg, false)
      end
    `}`
  end

  def add_message(message, scroll = true)
    messages_el = get_target(:messages)

    msg_el = create_element('div')
    add_class(msg_el, 'message')

    username = `#{message}.username`
    is_own = `#{username} === this.usernameValue`
    add_class(msg_el, 'own-message') if is_own

    time = `new Date(#{message}.timestamp).toLocaleTimeString()`
    text = escape_html(`#{message}.text`)

    set_html(msg_el, <<~HTML)
      <div class="message-header">
        <span class="message-username">#{username}</span>
        <span class="message-time">#{time}</span>
      </div>
      <div class="message-text">#{text}</div>
    HTML

    append_child(messages_el, msg_el)
    scroll_to_bottom if scroll
  end

  def add_system_message(message, scroll = true)
    messages_el = get_target(:messages)

    msg_el = create_element('div')
    add_class(msg_el, 'system-message')
    set_text(msg_el, `#{message}.text`)

    append_child(messages_el, msg_el)
    scroll_to_bottom if scroll
  end

  def update_user_count(count)
    return unless has_target?(:userCount)
    suffix = count == 1 ? ' online' : 's online'
    target_set_text(:userCount, "#{count} user#{suffix}")
  end

  def update_typing_indicator(message)
    return unless has_target?(:typingIndicator)

    if `#{message}.isTyping`
      username = `#{message}.username`
      target_set_text(:typingIndicator, "#{username} is typing...")
      show_target(:typingIndicator)
    else
      hide_target(:typingIndicator)
    end
  end

  def scroll_to_bottom
    messages_el = get_target(:messages)
    `#{messages_el}.scrollTop = #{messages_el}.scrollHeight`
  end

  def escape_html(text)
    el = create_element('div')
    set_text(el, text)
    `#{el}.innerHTML`
  end
end
