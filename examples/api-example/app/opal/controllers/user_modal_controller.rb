# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

# User modal controller for displaying user details
class UserModalController < StimulusController
  include JsProxyEx
  include DomHelpers

  self.targets = %w[
    overlay
    content
    userName
    userEmail
    userCompany
    userAddress
    userPhone
    userWebsite
    postsList
  ]

  def connect
    puts 'User modal controller connected!'
    setup_event_listener
  end

  # Stimulus action: Open modal
  def open
    `
      this.element.classList.add('active');
      if (this.hasOverlayTarget) this.overlayTarget.classList.add('active');
      if (this.hasContentTarget) this.contentTarget.classList.add('active');
      document.body.style.overflow = 'hidden';
    `
  end

  # Stimulus action: Close modal
  def close
    `
      this.element.classList.remove('active');
      if (this.hasOverlayTarget) this.overlayTarget.classList.remove('active');
      if (this.hasContentTarget) this.contentTarget.classList.remove('active');
      document.body.style.overflow = '';
    `
  end

  # Stimulus action: Close on overlay click
  def close_on_overlay(event)
    `
      if (this.hasOverlayTarget && event.target === this.overlayTarget) {
        #{close}
      }
    `
  end

  # Stimulus action: Close on Escape key
  def close_on_escape(event)
    close if event.key == 'Escape'
  end

  private

  def setup_event_listener
    `
      const ctrl = this;
      window.addEventListener('show-user-modal', function(e) {
        const user = e.detail.user;
        const posts = e.detail.posts;
        ctrl.$display_user(user, posts);
        ctrl.$open();
      });
    `
  end

  def display_user(user, posts)
    update_user_info(user)
    display_posts(posts)
  end

  def update_user_info(user)
    `
      if (this.hasUserNameTarget) this.userNameTarget.textContent = #{user}.name;
      if (this.hasUserEmailTarget) this.userEmailTarget.textContent = #{user}.email;
      if (this.hasUserCompanyTarget) this.userCompanyTarget.textContent = #{user}.company.name;
      if (this.hasUserPhoneTarget) this.userPhoneTarget.textContent = #{user}.phone;
      if (this.hasUserWebsiteTarget) this.userWebsiteTarget.textContent = #{user}.website;
      if (this.hasUserAddressTarget) {
        const street = #{user}.address.street;
        const city = #{user}.address.city;
        this.userAddressTarget.textContent = street + ', ' + city;
      }
    `
  end

  def display_posts(posts)
    return unless `this.hasPostsListTarget`

    `this.postsListTarget.innerHTML = ''`

    posts_length = `#{posts}.length`
    if posts_length == 0
      `this.postsListTarget.innerHTML = '<p class="no-posts">No posts yet</p>'`
      return
    end

    displayed_count = [posts_length, 5].min
    displayed_count.times do |i|
      post = `#{posts}[#{i}]`
      append_post_item(post)
    end

    if posts_length > 5
      more_text = "+ #{posts_length - 5} more posts"
      `
        const more = document.createElement('p');
        more.className = 'more-posts';
        more.textContent = #{more_text};
        this.postsListTarget.appendChild(more);
      `
    end
  end

  def append_post_item(post)
    title = `#{post}.title`
    body = `#{post}.body`
    html = "<h4>#{title}</h4><p>#{body}</p>"

    `
      const postItem = document.createElement('div');
      postItem.className = 'post-item';
      postItem.innerHTML = #{html};
      this.postsListTarget.appendChild(postItem);
    `
  end
end
