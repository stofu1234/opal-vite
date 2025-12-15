# backtick_javascript: true

# Users controller demonstrating API integration with fetch
class UsersController < StimulusController
  self.targets = ["list", "loading", "error"]

  def connect
    puts "Users controller connected!"
    fetch_users
  end

  # Fetch users from API
  def fetch_users
    `
      const ctrl = this;

      // Show loading state
      if (ctrl.hasLoadingTarget) {
        ctrl.loadingTarget.style.display = 'block';
      }
      if (ctrl.hasErrorTarget) {
        ctrl.errorTarget.style.display = 'none';
      }
      if (ctrl.hasListTarget) {
        ctrl.listTarget.innerHTML = '';
      }

      // Fetch data from JSONPlaceholder API
      fetch('https://jsonplaceholder.typicode.com/users')
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(users => {
          // Hide loading
          if (ctrl.hasLoadingTarget) {
            ctrl.loadingTarget.style.display = 'none';
          }

          // Display users
          users.forEach(user => {
            ctrl.addUserToDOM(user);
          });
        })
        .catch(error => {
          console.error('Error fetching users:', error);

          // Hide loading
          if (ctrl.hasLoadingTarget) {
            ctrl.loadingTarget.style.display = 'none';
          }

          // Show error
          if (ctrl.hasErrorTarget) {
            ctrl.errorTarget.textContent = 'Failed to load users. Please try again.';
            ctrl.errorTarget.style.display = 'block';
          }
        });
    `
  end

  # Reload users
  def reload
    fetch_users
  end

  # Show user details
  def show_user
    `
      const userId = parseInt(event.currentTarget.getAttribute('data-user-id'));

      // Fetch user details and posts
      Promise.all([
        fetch('https://jsonplaceholder.typicode.com/users/' + userId).then(r => r.json()),
        fetch('https://jsonplaceholder.typicode.com/posts?userId=' + userId).then(r => r.json())
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

  def add_user_to_dom
    `
      const user = arguments[0];
      const ctrl = this;

      const card = document.createElement('div');
      card.className = 'user-card';
      card.setAttribute('data-user-id', user.id);
      card.onclick = () => ctrl.showUser.call(ctrl, { currentTarget: card });

      card.innerHTML = '<div class="user-header">' +
        '<div class="user-avatar">' + user.name.charAt(0) + '</div>' +
        '<div class="user-info">' +
          '<h3>' + user.name + '</h3>' +
          '<p class="user-email">' + user.email + '</p>' +
        '</div>' +
      '</div>' +
      '<div class="user-details">' +
        '<div class="detail-item">' +
          '<span class="detail-label">Company:</span>' +
          '<span class="detail-value">' + user.company.name + '</span>' +
        '</div>' +
        '<div class="detail-item">' +
          '<span class="detail-label">City:</span>' +
          '<span class="detail-value">' + user.address.city + '</span>' +
        '</div>' +
        '<div class="detail-item">' +
          '<span class="detail-label">Phone:</span>' +
          '<span class="detail-value">' + user.phone + '</span>' +
        '</div>' +
      '</div>';

      ctrl.listTarget.appendChild(card);
    `
  end

  # Helper to create user card (called from JavaScript)
  def add_user_to_d_o_m(user)
    `this.addUserToDOM(arguments[0])`
  end
end
