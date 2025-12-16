# backtick_javascript: true

# Users controller demonstrating API integration with fetch
class UsersController < StimulusController
  include StimulusHelpers

  self.targets = ["list", "loading", "error"]

  def connect
    puts "Users controller connected!"
    fetch_users
  end

  # Fetch users from API
  def fetch_users
    show_loading
    hide_error
    target_set_html(:list, '') if has_target?(:list)

    # Fetch data from JSONPlaceholder API
    `
      const ctrl = this;

      fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(users => {
          ctrl.$hide_loading();
          users.forEach(user => ctrl.$add_user_to_dom(user));
        })
        .catch(error => {
          console.error('Error fetching users:', error);
          ctrl.$hide_loading();
          ctrl.$show_error('Failed to load users. Please try again.');
        });
    `
  end

  # Reload users
  def reload
    fetch_users
  end

  # Show user details
  def show_user
    user_id = event_data_int('user-id')

    # Fetch user details and posts
    `
      const ctrl = this;

      Promise.all([
        fetch('https://jsonplaceholder.typicode.com/users/' + #{user_id}).then(r => r.json()),
        fetch('https://jsonplaceholder.typicode.com/posts?userId=' + #{user_id}).then(r => r.json())
      ])
        .then(([user, posts]) => {
          // Dispatch event to show modal with user details
          const modalEvent = new CustomEvent('show-user-modal', {
            detail: { user, posts }
          });
          window.dispatchEvent(modalEvent);
        })
        .catch(error => {
          console.error('Error fetching user details:', error);
          alert('Failed to load user details');
        });
    `
  end

  private

  def add_user_to_dom(user)
    list = get_target(:list)

    card = create_element('div')
    add_class(card, 'user-card')
    set_attr(card, 'data-user-id', `#{user}.id`)

    # Set click handler
    `#{card}.onclick = () => this.$show_user.call(this, { currentTarget: #{card} })`

    name = `#{user}.name`
    email = `#{user}.email`
    company = `#{user}.company.name`
    city = `#{user}.address.city`
    phone = `#{user}.phone`
    initial = `#{name}.charAt(0)`

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
