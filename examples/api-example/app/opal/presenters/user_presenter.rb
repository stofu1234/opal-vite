# backtick_javascript: true

# UserPresenter - Handles user display/rendering logic
#
# This presenter encapsulates the HTML generation and DOM manipulation
# for displaying user data. Controllers should use this presenter
# for all user-related rendering.
#
# Usage:
#   presenter = UserPresenter.new
#   card = presenter.render_card(user) { |user_id| show_user(user_id) }
#   presenter.append_to(container, card)
#
class UserPresenter
  include StimulusHelpers

  # Render a user card element
  #
  # @param user [Native] JavaScript user object
  # @yield [user_id] Block called when card is clicked
  # @return [Native] DOM element for the user card
  def render_card(user, &on_click)
    card = create_element('div')
    add_class(card, 'user-card')

    user_id = js_get(user, :id)
    set_attr(card, 'data-user-id', user_id)

    # Set click handler if block given
    if on_click
      js_define_method_on(card, :onclick) do
        on_click.call(user_id)
      end
    end

    # Build card HTML
    set_html(card, build_card_html(user))
    card
  end

  # Render multiple user cards into a container
  #
  # @param container [Native] DOM container element
  # @param users [Native] JavaScript array of user objects
  # @yield [user_id] Block called when any card is clicked
  def render_list(container, users, &on_click)
    set_html(container, '')
    js_each(users) do |user|
      card = render_card(user, &on_click)
      append_child(container, card)
    end
  end

  # Append a card to a container
  #
  # @param container [Native] DOM container element
  # @param card [Native] Card element to append
  def append_to(container, card)
    append_child(container, card)
  end

  # Extract user display data as a Ruby hash
  #
  # @param user [Native] JavaScript user object
  # @return [Hash] User data for display
  def extract_display_data(user)
    {
      id: js_get(user, :id),
      name: js_get(user, :name),
      email: js_get(user, :email),
      phone: js_get(user, :phone),
      website: js_get(user, :website),
      company: js_get(js_get(user, :company), :name),
      city: js_get(js_get(user, :address), :city),
      street: js_get(js_get(user, :address), :street),
      initial: js_string_char_at(js_get(user, :name), 0)
    }
  end

  # Format full address from user object
  #
  # @param user [Native] JavaScript user object
  # @return [String] Formatted address
  def format_address(user)
    address = js_get(user, :address)
    street = js_get(address, :street)
    city = js_get(address, :city)
    "#{street}, #{city}"
  end

  private

  def build_card_html(user)
    data = extract_display_data(user)

    <<~HTML
      <div class="user-header">
        <div class="user-avatar">#{data[:initial]}</div>
        <div class="user-info">
          <h3>#{data[:name]}</h3>
          <p class="user-email">#{data[:email]}</p>
        </div>
      </div>
      <div class="user-details">
        <div class="detail-item">
          <span class="detail-label">Company:</span>
          <span class="detail-value">#{data[:company]}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">City:</span>
          <span class="detail-value">#{data[:city]}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">Phone:</span>
          <span class="detail-value">#{data[:phone]}</span>
        </div>
      </div>
    HTML
  end
end
