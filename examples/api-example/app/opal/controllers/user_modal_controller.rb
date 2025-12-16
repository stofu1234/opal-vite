# backtick_javascript: true

# User modal controller for displaying user details
class UserModalController < StimulusController
  include StimulusHelpers

  self.targets = ["overlay", "content", "userName", "userEmail", "userCompany", "userAddress", "userPhone", "userWebsite", "postsList"]

  def connect
    puts "User modal controller connected!"

    # Listen for show-user-modal event
    on_window_event('show-user-modal') do |e|
      detail = `#{e}.detail`
      user = `#{detail}.user`
      posts = `#{detail}.posts`
      display_user(user, posts)
      open
    end
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
    close if `#{target} === #{overlay}`
  end

  # Close on Escape key
  def close_on_escape
    close if event_key == 'Escape'
  end

  private

  def display_user(user, posts)
    # Update user info
    target_set_text(:userName, `#{user}.name`) if has_target?(:userName)
    target_set_text(:userEmail, `#{user}.email`) if has_target?(:userEmail)
    target_set_text(:userCompany, `#{user}.company.name`) if has_target?(:userCompany)
    target_set_text(:userPhone, `#{user}.phone`) if has_target?(:userPhone)
    target_set_text(:userWebsite, `#{user}.website`) if has_target?(:userWebsite)

    if has_target?(:userAddress)
      address = "#{`#{user}.address.street`}, #{`#{user}.address.city`}"
      target_set_text(:userAddress, address)
    end

    # Display posts
    display_posts(posts) if has_target?(:postsList)
  end

  def display_posts(posts)
    posts_list = get_target(:postsList)
    set_html(posts_list, '')

    length = `#{posts}.length`

    if `#{length} === 0`
      set_html(posts_list, '<p class="no-posts">No posts yet</p>')
    else
      # Show first 5 posts
      limit = `Math.min(#{length}, 5)`
      `for (var i = 0; i < #{limit}; i++) {`
        post = `#{posts}[i]`
        post_item = create_element('div')
        add_class(post_item, 'post-item')
        set_html(post_item, "<h4>#{`#{post}.title`}</h4><p>#{`#{post}.body`}</p>")
        append_child(posts_list, post_item)
      `}`

      # Show "more posts" indicator if needed
      if `#{length} > 5`
        more = create_element('p')
        add_class(more, 'more-posts')
        remaining = `#{length} - 5`
        set_text(more, "+ #{remaining} more posts")
        append_child(posts_list, more)
      end
    end
  end
end
