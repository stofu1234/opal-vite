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

    return if `#{text} === ''` || !js_prop(:isConnected)

    ws = js_prop(:ws)
    js_call_on(ws, :send, json_stringify({ type: 'message', text: text }))

    target_set_value(:input, '')

    # Send typing stopped
    js_call_on(ws, :send, json_stringify({ type: 'typing', isTyping: false }))
  end

  # Handle input keypress
  def handle_keypress
    if event_key == 'Enter' && !`event.shiftKey`
      prevent_default
      send_message
      return
    end

    # Send typing indicator
    return unless js_prop(:isConnected)

    ws = js_prop(:ws)
    js_call_on(ws, :send, json_stringify({ type: 'typing', isTyping: true }))

    typing_timeout = js_prop(:typingTimeout)
    clear_timeout(typing_timeout) if typing_timeout

    new_timeout = set_timeout(1000) do
      ws = js_prop(:ws)
      js_call_on(ws, :send, json_stringify({ type: 'typing', isTyping: false })) if ws
    end
    js_set_prop(:typingTimeout, new_timeout)
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
    js_set_prop(:usernameValue, username)

    # Send join message if connected
    if js_prop(:isConnected)
      ws = js_prop(:ws)
      js_call_on(ws, :send, json_stringify({ type: 'join', username: username }))
    end

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
    js_set_prop(:ws, nil)
    js_set_prop(:isConnected, false)
    js_set_prop(:typingTimeout, nil)

    # Define connectWebSocket function
    js_define_method(:connectWebSocket) do
      protocol = `window.location.protocol === 'https:' ? 'wss:' : 'ws:'`
      ws_url = `#{protocol} + '//' + window.location.hostname + ':3007'`

      ws = js_new(js_global('WebSocket'), ws_url)
      js_set_prop(:ws, ws)

      # onopen handler
      js_define_method_on(ws, :onopen) do
        console_log('✅ Connected to WebSocket server')
        js_set_prop(:isConnected, true)
        username = js_prop(:usernameValue)
        if username
          js_call_on(ws, :send, json_stringify({ type: 'join', username: username }))
        end
      end

      # onmessage handler
      js_define_method_on(ws, :onmessage) do |event|
        data = json_parse(`#{event}.data`)
        handle_message(data)
      end

      # onclose handler
      js_define_method_on(ws, :onclose) do
        console_log('❌ Disconnected from WebSocket server')
        js_set_prop(:isConnected, false)
        set_timeout(3000) do
          console_log('🔄 Attempting to reconnect...')
          js_call(:connectWebSocket)
        end
      end

      # onerror handler
      js_define_method_on(ws, :onerror) do |error|
        console_error('WebSocket error:', error)
      end
    end

    js_call(:connectWebSocket)
  end

  def handle_message(message)
    type = js_get(message, :type)

    case type
    when 'history'
      load_history(js_get(message, :messages))
    when 'message'
      add_message(message)
    when 'system'
      add_system_message(message)
    when 'user_count'
      update_user_count(js_get(message, :count))
    when 'typing'
      update_typing_indicator(message)
    end
  end

  def load_history(messages)
    length = js_length(messages)
    length.times do |i|
      msg = `#{messages}[#{i}]`
      msg_type = js_get(msg, :type)

      if msg_type == 'message'
        add_message(msg, false)
      elsif msg_type == 'system'
        add_system_message(msg, false)
      end
    end
  end

  def add_message(message, scroll = true)
    messages_el = get_target(:messages)

    msg_el = create_element('div')
    add_class(msg_el, 'message')

    username = js_get(message, :username)
    is_own = `#{username} === this.usernameValue`
    add_class(msg_el, 'own-message') if is_own

    timestamp = js_get(message, :timestamp)
    time = `new Date(#{timestamp}).toLocaleTimeString()`
    text = escape_html(js_get(message, :text))

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
    set_text(msg_el, js_get(message, :text))

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

    if js_get(message, :isTyping)
      username = js_get(message, :username)
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
