# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

# Users controller demonstrating API integration with fetch
class UsersController < StimulusController
  include JsProxyEx
  include DomHelpers

  self.targets = %w[list loading error]

  API_BASE = 'https://jsonplaceholder.typicode.com'.freeze

  def connect
    puts 'Users controller connected!'
    fetch_users
  end

  # Stimulus action: Reload users
  def reload
    fetch_users
  end

  # Stimulus action: Show user details (called via onclick)
  def show_user(event)
    user_id = event.current_target.get_attribute('data-user-id').to_i

    show_loading
    fetch_user_with_posts(user_id)
  end

  private

  def fetch_users
    show_loading
    hide_error
    clear_list

    `
      const ctrl = this;
      fetch(#{API_BASE} + '/users')
        .then(function(response) {
          if (!response.ok) throw new Error('Network response was not ok');
          return response.json();
        })
        .then(function(users) {
          ctrl.$hide_loading();
          users.forEach(function(user) {
            ctrl.$add_user_to_dom(user);
          });
        })
        .catch(function(error) {
          console.error('Error fetching users:', error);
          ctrl.$hide_loading();
          ctrl.$show_error_message('Failed to load users. Please try again.');
        });
    `
  end

  def fetch_user_with_posts(user_id)
    `
      const ctrl = this;
      Promise.all([
        fetch(#{API_BASE} + '/users/' + #{user_id}).then(function(r) { return r.json(); }),
        fetch(#{API_BASE} + '/posts?userId=' + #{user_id}).then(function(r) { return r.json(); })
      ])
        .then(function(results) {
          const user = results[0];
          const posts = results[1];
          ctrl.$hide_loading();
          ctrl.$dispatch_user_modal(user, posts);
        })
        .catch(function(error) {
          console.error('Error fetching user details:', error);
          ctrl.$hide_loading();
          alert('Failed to load user details');
        });
    `
  end

  def dispatch_user_modal(user, posts)
    `
      const modalEvent = new CustomEvent('show-user-modal', {
        detail: { user: user, posts: posts }
      });
      window.dispatchEvent(modalEvent);
    `
  end

  def add_user_to_dom(js_user)
    return unless `this.hasListTarget`

    card = create_user_card(js_user)
    `this.listTarget.appendChild(#{card.to_n})`
  end

  def create_user_card(user)
    card = document.create_element('div')
    card.class_name = 'user-card'
    card.set_attribute('data-user-id', `#{user}.id`)
    card.set_attribute('data-action', 'click->users#show_user')

    name = `#{user}.name`
    email = `#{user}.email`
    company = `#{user}.company.name`
    city = `#{user}.address.city`
    phone = `#{user}.phone`
    initial = `#{user}.name.charAt(0)`

    card.inner_html = build_user_card_html(initial, name, email, company, city, phone)
    card
  end

  def build_user_card_html(initial, name, email, company, city, phone)
    "<div class=\"user-header\">" \
      "<div class=\"user-avatar\">#{initial}</div>" \
      "<div class=\"user-info\">" \
        "<h3>#{name}</h3>" \
        "<p class=\"user-email\">#{email}</p>" \
      "</div>" \
    "</div>" \
    "<div class=\"user-details\">" \
      "<div class=\"detail-item\">" \
        "<span class=\"detail-label\">Company:</span>" \
        "<span class=\"detail-value\">#{company}</span>" \
      "</div>" \
      "<div class=\"detail-item\">" \
        "<span class=\"detail-label\">City:</span>" \
        "<span class=\"detail-value\">#{city}</span>" \
      "</div>" \
      "<div class=\"detail-item\">" \
        "<span class=\"detail-label\">Phone:</span>" \
        "<span class=\"detail-value\">#{phone}</span>" \
      "</div>" \
    "</div>"
  end

  def show_loading
    `
      if (this.hasLoadingTarget) {
        this.loadingTarget.style.display = 'block';
      }
    `
  end

  def hide_loading
    `
      if (this.hasLoadingTarget) {
        this.loadingTarget.style.display = 'none';
      }
    `
  end

  def show_error_message(message)
    `
      if (this.hasErrorTarget) {
        this.errorTarget.textContent = #{message};
        this.errorTarget.style.display = 'block';
      }
    `
  end

  def hide_error
    `
      if (this.hasErrorTarget) {
        this.errorTarget.style.display = 'none';
      }
    `
  end

  def clear_list
    `
      if (this.hasListTarget) {
        this.listTarget.innerHTML = '';
      }
    `
  end
end
