# backtick_javascript: true

# UsersController - UI coordination for user list
#
# This controller is responsible for:
# - UI state management (loading, error states)
# - Coordinating between UserService and UserPresenter
# - Handling user interactions (reload, show user)
#
# API communication is delegated to UserService
# HTML rendering is delegated to UserPresenter
#
class UsersController < StimulusController
  include StimulusHelpers

  self.targets = ["list", "loading", "error"]

  def connect
    puts "Users controller connected!"
    @user_service = UserService.new
    @user_presenter = UserPresenter.new
    load_users
  end

  # Reload users list
  def reload
    load_users
  end

  # Show user details (triggered by data-action)
  def show_user
    user_id = event_data_int('user-id')
    fetch_and_show_user(user_id)
  end

  private

  # Load and display all users
  def load_users
    show_loading
    hide_error
    clear_list

    @user_service.fetch_all(
      on_success: ->(users) { handle_users_loaded(users) },
      on_error: ->(error) { handle_load_error(error) }
    )
  end

  # Handle successful user list load
  def handle_users_loaded(users)
    hide_loading
    render_users(users)
  end

  # Handle user list load error
  def handle_load_error(error)
    console_error('Error fetching users:', error)
    hide_loading
    show_error('Failed to load users. Please try again.')
  end

  # Render users using presenter
  def render_users(users)
    return unless has_target?(:list)

    list = get_target(:list)
    @user_presenter.render_list(list, users) do |user_id|
      fetch_and_show_user(user_id)
    end
  end

  # Fetch user with posts and dispatch modal event
  def fetch_and_show_user(user_id)
    @user_service.fetch_with_posts(user_id,
      on_success: ->(data) { show_user_modal(data) },
      on_error: ->(error) { handle_user_fetch_error(error) }
    )
  end

  # Show user modal with fetched data
  def show_user_modal(data)
    dispatch_window_event('show-user-modal', {
      user: data[:user],
      posts: data[:posts]
    })
  end

  # Handle user fetch error
  def handle_user_fetch_error(error)
    console_error('Error fetching user details:', error)
    `alert('Failed to load user details')`
  end

  # UI helper methods
  def clear_list
    target_set_html(:list, '') if has_target?(:list)
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
