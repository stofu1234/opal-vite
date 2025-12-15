# backtick_javascript: true

# User modal controller for displaying user details
class UserModalController < StimulusController
  self.targets = ["overlay", "content", "userName", "userEmail", "userCompany", "userAddress", "userPhone", "userWebsite", "postsList"]

  def connect
    puts "User modal controller connected!"

    # Set up helper methods
    `
      const ctrl = this;

      // Define displayUser helper
      this.displayUser = function(user, posts) {
        // Update user info
        if (ctrl.hasUserNameTarget) {
          ctrl.userNameTarget.textContent = user.name;
        }
        if (ctrl.hasUserEmailTarget) {
          ctrl.userEmailTarget.textContent = user.email;
        }
        if (ctrl.hasUserCompanyTarget) {
          ctrl.userCompanyTarget.textContent = user.company.name;
        }
        if (ctrl.hasUserAddressTarget) {
          ctrl.userAddressTarget.textContent = user.address.street + ', ' + user.address.city;
        }
        if (ctrl.hasUserPhoneTarget) {
          ctrl.userPhoneTarget.textContent = user.phone;
        }
        if (ctrl.hasUserWebsiteTarget) {
          ctrl.userWebsiteTarget.textContent = user.website;
        }

        // Display posts
        if (ctrl.hasPostsListTarget) {
          ctrl.postsListTarget.innerHTML = '';

          if (posts.length === 0) {
            ctrl.postsListTarget.innerHTML = '<p class="no-posts">No posts yet</p>';
          } else {
            posts.slice(0, 5).forEach(post => {
              const postItem = document.createElement('div');
              postItem.className = 'post-item';
              postItem.innerHTML = '<h4>' + post.title + '</h4>' +
                '<p>' + post.body + '</p>';
              ctrl.postsListTarget.appendChild(postItem);
            });

            if (posts.length > 5) {
              const more = document.createElement('p');
              more.className = 'more-posts';
              more.textContent = '+ ' + (posts.length - 5) + ' more posts';
              ctrl.postsListTarget.appendChild(more);
            }
          }
        }
      };

      // Listen for show-user-modal event
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

end
