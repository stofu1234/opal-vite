# backtick_javascript: true

# PostPresenter - Handles post display/rendering logic
#
# This presenter encapsulates the HTML generation and DOM manipulation
# for displaying post data (used in user modal).
#
# Usage:
#   presenter = PostPresenter.new
#   presenter.render_list(container, posts, max: 5)
#
class PostPresenter
  include StimulusHelpers

  DEFAULT_MAX_POSTS = 5

  # Render a list of posts into a container
  #
  # @param container [Native] DOM container element
  # @param posts [Native] JavaScript array of post objects
  # @param max [Integer] Maximum number of posts to display
  def render_list(container, posts, max: DEFAULT_MAX_POSTS)
    set_html(container, '')

    length = js_length(posts)

    if length == 0
      render_empty_state(container)
    else
      render_posts(container, posts, length, max)
      render_more_indicator(container, length, max) if length > max
    end
  end

  # Render a single post item
  #
  # @param post [Native] JavaScript post object
  # @return [Native] DOM element for the post
  def render_item(post)
    item = create_element('div')
    add_class(item, 'post-item')

    title = js_get(post, :title)
    body = js_get(post, :body)
    set_html(item, build_post_html(title, body))

    item
  end

  # Extract post display data as a Ruby hash
  #
  # @param post [Native] JavaScript post object
  # @return [Hash] Post data for display
  def extract_display_data(post)
    {
      id: js_get(post, :id),
      user_id: js_get(post, :userId),
      title: js_get(post, :title),
      body: js_get(post, :body)
    }
  end

  private

  def render_empty_state(container)
    set_html(container, '<p class="no-posts">No posts yet</p>')
  end

  def render_posts(container, posts, length, max)
    limit = js_min(length, max)

    limit.times do |i|
      post = js_array_at(posts, i)
      item = render_item(post)
      append_child(container, item)
    end
  end

  def render_more_indicator(container, total, max)
    more = create_element('p')
    add_class(more, 'more-posts')
    remaining = total - max
    set_text(more, "+ #{remaining} more posts")
    append_child(container, more)
  end

  def build_post_html(title, body)
    "<h4>#{title}</h4><p>#{body}</p>"
  end
end
