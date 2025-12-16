# backtick_javascript: true

# Users controller demonstrating API integration with fetch
class UsersController < StimulusController
  include StimulusHelpers

  self.targets = ["list", "loading", "error"]

  API_BASE = 'https://jsonplaceholder.typicode.com'

  def connect
    puts "Users controller connected!"
    fetch_users
  end

  # Fetch users from API
  def fetch_users
    show_loading
    hide_error
    target_set_html(:list, '') if has_target?(:list)

    # Fetch data from JSONPlaceholder API using Ruby-style helpers
    promise = fetch_json_safe("#{API_BASE}/users")

    promise = js_then(promise) do |users|
      hide_loading
      js_each(users) { |user| add_user_to_dom(user) }
    end

    js_catch(promise) do |error|
      console_error('Error fetching users:', error)
      hide_loading
      show_error('Failed to load users. Please try again.')
    end
  end

  # Reload users
  def reload
    fetch_users
  end

  # Show user details
  def show_user
    user_id = event_data_int('user-id')

    # Fetch user details and posts in parallel using Ruby-style helpers
    urls = [
      "#{API_BASE}/users/#{user_id}",
      "#{API_BASE}/posts?userId=#{user_id}"
    ]

    promise = fetch_all_json(urls)

    promise = js_then(promise) do |results|
      user = js_array_at(results, 0)
      posts = js_array_at(results, 1)

      dispatch_window_event('show-user-modal', {
        user: user,
        posts: posts
      })
    end

    js_catch(promise) do |error|
      console_error('Error fetching user details:', error)
      `alert('Failed to load user details')`
    end
  end

  private

  def add_user_to_dom(user)
    list = get_target(:list)

    card = create_element('div')
    add_class(card, 'user-card')

    user_id = js_get(user, :id)
    set_attr(card, 'data-user-id', user_id)

    # Set click handler using Ruby block
    js_define_method_on(card, :onclick) do
      show_user_by_id(user_id)
    end

    # Extract user properties
    name = js_get(user, :name)
    email = js_get(user, :email)
    company = js_get(js_get(user, :company), :name)
    address = js_get(user, :address)
    city = js_get(address, :city)
    phone = js_get(user, :phone)
    initial = js_string_char_at(name, 0)

    html = <<~HTML
      <div class="user-header">
        <div class="user-avatar">#{initial}</div>
        <div class="user-info">
          <h3>#{name}</h3>
          <p class="user-email">#{email}</p>
        </div>
      </div>
      <div class="user-details">
        <div class="detail-item">
          <span class="detail-label">Company:</span>
          <span class="detail-value">#{company}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">City:</span>
          <span class="detail-value">#{city}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">Phone:</span>
          <span class="detail-value">#{phone}</span>
        </div>
      </div>
    HTML

    set_html(card, html)
    append_child(list, card)
  end

  # Helper method for onclick handler
  def show_user_by_id(user_id)
    # Fetch user details and posts in parallel
    urls = [
      "#{API_BASE}/users/#{user_id}",
      "#{API_BASE}/posts?userId=#{user_id}"
    ]

    promise = fetch_all_json(urls)

    promise = js_then(promise) do |results|
      user = js_array_at(results, 0)
      posts = js_array_at(results, 1)

      dispatch_window_event('show-user-modal', {
        user: user,
        posts: posts
      })
    end

    js_catch(promise) do |error|
      console_error('Error fetching user details:', error)
      `alert('Failed to load user details')`
    end
  end

  def show_loading
    show_target(:loading) if has_target?(:loading)
  end

  def hide_loading
    hide_target(:loading) if has_target?(:loading)
  end

  def show_error(message)
    if has_target?(:error)
      target_set_text(:error, message)
      show_target(:error)
    end
  end

  def hide_error
    hide_target(:error) if has_target?(:error)
  end
end
