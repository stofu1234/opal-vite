# backtick_javascript: true

# UserService - Handles all user-related API communication
#
# This service encapsulates API calls and provides a clean interface
# for fetching user data. Controllers should use this service instead
# of making direct API calls.
#
# Usage:
#   service = UserService.new
#   service.fetch_all(
#     on_success: ->(users) { render_users(users) },
#     on_error: ->(error) { show_error(error) }
#   )
#
class UserService
  include StimulusHelpers

  API_BASE = 'https://jsonplaceholder.typicode.com'.freeze

  # Fetch all users from the API
  #
  # @param on_success [Proc] Callback with users array on success
  # @param on_error [Proc] Callback with error on failure
  def fetch_all(on_success:, on_error: nil)
    promise = fetch_json_safe("#{API_BASE}/users")

    promise = js_then(promise) do |users|
      on_success.call(users)
    end

    js_catch(promise) do |error|
      if on_error
        on_error.call(error)
      else
        console_error('UserService: Error fetching users', error)
      end
    end
  end

  # Fetch a single user with their posts
  #
  # @param user_id [Integer] The user ID to fetch
  # @param on_success [Proc] Callback with { user:, posts: } hash on success
  # @param on_error [Proc] Callback with error on failure
  def fetch_with_posts(user_id, on_success:, on_error: nil)
    urls = [
      "#{API_BASE}/users/#{user_id}",
      "#{API_BASE}/posts?userId=#{user_id}"
    ]

    promise = fetch_all_json(urls)

    promise = js_then(promise) do |results|
      user = js_array_at(results, 0)
      posts = js_array_at(results, 1)
      on_success.call(user: user, posts: posts)
    end

    js_catch(promise) do |error|
      if on_error
        on_error.call(error)
      else
        console_error('UserService: Error fetching user with posts', error)
      end
    end
  end

  # Fetch a single user by ID
  #
  # @param user_id [Integer] The user ID to fetch
  # @param on_success [Proc] Callback with user object on success
  # @param on_error [Proc] Callback with error on failure
  def fetch_one(user_id, on_success:, on_error: nil)
    promise = fetch_json_safe("#{API_BASE}/users/#{user_id}")

    promise = js_then(promise) do |user|
      on_success.call(user)
    end

    js_catch(promise) do |error|
      if on_error
        on_error.call(error)
      else
        console_error('UserService: Error fetching user', error)
      end
    end
  end

  # Fetch posts for a specific user
  #
  # @param user_id [Integer] The user ID
  # @param on_success [Proc] Callback with posts array on success
  # @param on_error [Proc] Callback with error on failure
  def fetch_posts(user_id, on_success:, on_error: nil)
    promise = fetch_json_safe("#{API_BASE}/posts?userId=#{user_id}")

    promise = js_then(promise) do |posts|
      on_success.call(posts)
    end

    js_catch(promise) do |error|
      if on_error
        on_error.call(error)
      else
        console_error('UserService: Error fetching posts', error)
      end
    end
  end
end
