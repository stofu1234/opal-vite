# backtick_javascript: true

# UserModalController - UI coordination for user detail modal
#
# This controller is responsible for:
# - Modal open/close state management
# - Body scroll lock management
# - Coordinating with presenters for content display
#
# HTML rendering is delegated to UserPresenter and PostPresenter
#
class UserModalController < StimulusController
  include StimulusHelpers

  self.targets = ["overlay", "content", "userName", "userEmail", "userCompany",
                  "userAddress", "userPhone", "userWebsite", "postsList"]

  def connect
    puts "User modal controller connected!"
    @user_presenter = UserPresenter.new
    @post_presenter = PostPresenter.new
    setup_event_listener
  end

  # Open modal
  def open
    element_add_class('active')
    add_target_class(:overlay, 'active')
    add_target_class(:content, 'active')
    lock_body_scroll
  end

  # Close modal
  def close
    element_remove_class('active')
    remove_target_class(:overlay, 'active')
    remove_target_class(:content, 'active')
    unlock_body_scroll
  end

  # Close on overlay click
  def close_on_overlay
    target = event_target
    overlay = get_target(:overlay)
    close if js_equals?(target, overlay)
  end

  # Close on Escape key
  def close_on_escape
    close if event_key == 'Escape'
  end

  private

  def setup_event_listener
    on_window_event('show-user-modal') do |e|
      detail = js_get(e, :detail)
      user = js_get(detail, :user)
      posts = js_get(detail, :posts)
      display_user(user, posts)
      open
    end
  end

  def display_user(user, posts)
    display_user_info(user)
    display_user_posts(posts)
  end

  def display_user_info(user)
    # Use presenter to extract display data
    data = @user_presenter.extract_display_data(user)

    target_set_text(:userName, data[:name]) if has_target?(:userName)
    target_set_text(:userEmail, data[:email]) if has_target?(:userEmail)
    target_set_text(:userCompany, data[:company]) if has_target?(:userCompany)
    target_set_text(:userPhone, data[:phone]) if has_target?(:userPhone)
    target_set_text(:userWebsite, data[:website]) if has_target?(:userWebsite)

    if has_target?(:userAddress)
      address = @user_presenter.format_address(user)
      target_set_text(:userAddress, address)
    end
  end

  def display_user_posts(posts)
    return unless has_target?(:postsList)

    posts_list = get_target(:postsList)
    @post_presenter.render_list(posts_list, posts, max: 5)
  end
end
