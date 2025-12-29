# backtick_javascript: true

# Chat Controller using OpalVite ActionCableHelpers
# Demonstrates real-time WebSocket communication
class ChatController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::ActionCableHelpers

  # Stimulus targets
  self.targets = %w[
    status statusText usernamePanel usernameInput
    chatPanel currentUser messages typing input
    sendButton usersPanel userList
  ]

  def connect
    @username = nil
    @typing_timeout = nil
    update_status("disconnected", "Disconnected")
  end

  def disconnect
    cable_disconnect
  end

  def set_username
    username = target_value(:username_input).to_s.strip
    return if username.empty?

    @username = username
    show_chat_panel
    connect_to_chat
  end

  private

  def show_chat_panel
    hide_target(:username_panel)
    show_target(:chat_panel)
    show_target(:users_panel)
    target_set_text(:current_user, @username)
    target_focus(:input)
  end

  def connect_to_chat
    update_status("connecting", "Connecting...")

    # Connect to WebSocket server
    cable_connect("ws://localhost:3018/cable")

    # Subscribe to ChatChannel
    cable_subscribe("ChatChannel",
      params: { room: "general" },
      on_connected: -> { handle_connected },
      on_disconnected: -> { handle_disconnected },
      on_received: ->(data) { handle_received(data) },
      on_rejected: -> { handle_rejected }
    )
  end

  def handle_connected
    update_status("connected", "Connected")

    # Announce joining
    cable_perform(:join, username: @username)
  end

  def handle_disconnected
    update_status("disconnected", "Disconnected")
  end

  def handle_rejected
    update_status("disconnected", "Connection rejected")
  end

  def handle_received(data)
    # Route data based on type
    cable_route(data, {
      "message" => -> { display_message(data) },
      "typing" => -> { show_typing(data) },
      "presence" => -> { update_presence(data) },
      "system" => -> { display_system_message(data) }
    })
  end

  def display_message(data)
    user = cable_data(data, "user")
    text = cable_data(data, "text")
    time = cable_data(data, "time") || js_iso_date

    is_own = (user == @username)
    class_name = is_own ? "message own" : "message"

    html = <<~HTML
      <div class="#{class_name}">
        <div class="message-header">
          <span class="message-user">#{escape_html(user)}</span>
          <span class="message-time">#{format_time(time)}</span>
        </div>
        <div class="message-text">#{escape_html(text)}</div>
      </div>
    HTML

    append_message(html)
  end

  def display_system_message(data)
    text = cable_data(data, "text")

    html = <<~HTML
      <div class="message system">
        <div class="message-text">#{escape_html(text)}</div>
      </div>
    HTML

    append_message(html)
  end

  def append_message(html)
    messages = get_target(:messages)
    `#{messages}.insertAdjacentHTML('beforeend', #{html})`
    # Scroll to bottom
    `#{messages}.scrollTop = #{messages}.scrollHeight`
  end

  def show_typing(data)
    user = cable_data(data, "user")
    return if user == @username

    target_set_text(:typing, "#{user} is typing...")

    # Clear typing indicator after 2 seconds
    clear_timeout(@typing_clear_timeout) if @typing_clear_timeout
    @typing_clear_timeout = set_timeout(2000) do
      target_set_text(:typing, "")
    end
  end

  def update_presence(data)
    users = cable_data(data, "users")
    return unless users

    user_list = get_target(:user_list)
    html = ""

    `#{users}.forEach(function(user) {
      html += '<span class="user-badge"><span class="online-dot"></span>' + user + '</span>';
    })`

    set_html(user_list, html)
  end

  public

  def send_message
    text = target_value(:input).to_s.strip
    return if text.empty?

    cable_perform(:speak, text: text, user: @username)
    target_set_value(:input, "")
    target_focus(:input)
  end

  def on_typing
    # Debounce typing notifications
    throttled(1000, "typing") do
      cable_perform(:typing, user: @username)
    end
  end

  private

  def update_status(status, text)
    status_el = get_target(:status)
    `#{status_el}.className = 'connection-status ' + #{status}`
    target_set_text(:status_text, text)
  end

  def format_time(iso_string)
    date = js_date(iso_string)
    `#{date}.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })`
  end

  def escape_html(text)
    text.to_s
        .gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
        .gsub('"', "&quot;")
  end
end
