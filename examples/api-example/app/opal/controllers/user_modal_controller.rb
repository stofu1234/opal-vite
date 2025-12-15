# backtick_javascript: true

# User modal controller for displaying user details
class UserModalController < StimulusController
  self.targets = ["overlay", "content", "userName", "userEmail", "userCompany", "userAddress", "userPhone", "userWebsite", "postsList"]

  def connect
    puts "User modal controller connected!"

    # Listen for show-user-modal event
    `
      const ctrl = this;

      window.addEventListener('show-user-modal', (e) => {
        const { user, posts } = e.detail;
        ctrl.displayUser(user, posts);
        ctrl.open();
      });
    `
  end

  # Open modal
  def open
    `
      this.element.classList.add('active');
      this.overlayTarget.classList.add('active');
      this.contentTarget.classList.add('active');
      document.body.style.overflow = 'hidden';
    `
  end

  # Close modal
  def close
    `
      this.element.classList.remove('active');
      this.overlayTarget.classList.remove('active');
      this.contentTarget.classList.remove('active');
      document.body.style.overflow = '';
    `
  end

  # Close on overlay click
  def close_on_overlay
    `
      if (event.target === this.overlayTarget) {
        this.close();
      }
    `
  end

  # Close on Escape key
  def close_on_escape
    `
      if (event.key === 'Escape') {
        this.close();
      }
    `
  end

  private

  def display_user
    `
      const user = arguments[0];
      const posts = arguments[1];

      // Update user info
      if (this.hasUserNameTarget) {
        this.userNameTarget.textContent = user.name;
      }
      if (this.hasUserEmailTarget) {
        this.userEmailTarget.textContent = user.email;
      }
      if (this.hasUserCompanyTarget) {
        this.userCompanyTarget.textContent = user.company.name;
      }
      if (this.hasUserAddressTarget) {
        this.userAddressTarget.textContent = user.address.street + ', ' + user.address.city;
      }
      if (this.hasUserPhoneTarget) {
        this.userPhoneTarget.textContent = user.phone;
      }
      if (this.hasUserWebsiteTarget) {
        this.userWebsiteTarget.textContent = user.website;
      }

      // Display posts
      if (this.hasPostsListTarget) {
        this.postsListTarget.innerHTML = '';

        if (posts.length === 0) {
          this.postsListTarget.innerHTML = '<p class="no-posts">No posts yet</p>';
        } else {
          posts.slice(0, 5).forEach(post => {
            const postItem = document.createElement('div');
            postItem.className = 'post-item';
            postItem.innerHTML = '<h4>' + post.title + '</h4>' +
              '<p>' + post.body + '</p>';
            this.postsListTarget.appendChild(postItem);
          });

          if (posts.length > 5) {
            const more = document.createElement('p');
            more.className = 'more-posts';
            more.textContent = '+ ' + (posts.length - 5) + ' more posts';
            this.postsListTarget.appendChild(more);
          }
        }
      }
    `
  end
end
