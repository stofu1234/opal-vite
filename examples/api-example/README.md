# API Integration Example

A comprehensive example demonstrating API integration with Opal, Stimulus, and Vite. This example shows how to fetch data from external APIs, handle loading states, display dynamic content, and implement modals for detailed views.

## Features

- **Fetch API Integration**: Make HTTP requests to JSONPlaceholder API
- **Loading States**: Visual feedback during data fetching
- **Error Handling**: Graceful error messages on API failures
- **Dynamic Rendering**: Create DOM elements from API response data
- **Modal Views**: Display detailed information in a modal dialog
- **Parallel Requests**: Fetch multiple API endpoints simultaneously with Promise.all()
- **Event-Driven Communication**: Cross-controller communication using CustomEvents
- **Responsive Design**: Mobile-friendly layout and styling

## API Source

This example uses [JSONPlaceholder](https://jsonplaceholder.typicode.com/), a free fake REST API for testing and prototyping. It provides realistic data for users, posts, comments, and more.

## Getting Started

### Prerequisites

- Ruby 3.0 or higher
- Node.js 18 or higher
- pnpm (or npm/yarn)

### Installation

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
pnpm install

# Start the development server
pnpm dev
```

The app will be available at http://localhost:3004/

## Project Structure

```
api-example/
├── app/
│   ├── javascript/
│   │   └── application.js          # JavaScript entry point
│   ├── opal/
│   │   ├── application.rb           # Ruby entry point
│   │   └── controllers/
│   │       ├── users_controller.rb       # Users list controller
│   │       └── user_modal_controller.rb  # User detail modal controller
│   └── styles.css                  # Global styles
├── index.html                      # Main HTML template
├── vite.config.ts                  # Vite configuration
├── package.json                    # Node.js dependencies
└── Gemfile                         # Ruby dependencies
```

## Controller Architecture

### UsersController

The `UsersController` is responsible for fetching and displaying a list of users from the API.

**Targets:**
- `list` - Container for user cards
- `loading` - Loading spinner
- `error` - Error message container

**Key Methods:**

#### `connect`
Called when the controller is initialized. Automatically fetches users on page load.

```ruby
def connect
  puts "Users controller connected!"
  fetch_users
end
```

#### `fetch_users`
Fetches users from the JSONPlaceholder API, handles loading states, and renders the results.

```ruby
def fetch_users
  `
    const ctrl = this;

    // Show loading state
    if (ctrl.hasLoadingTarget) {
      ctrl.loadingTarget.style.display = 'block';
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
        if (ctrl.hasLoadingTarget) {
          ctrl.loadingTarget.style.display = 'none';
        }
        users.forEach(user => {
          ctrl.addUserToDOM(user);
        });
      })
      .catch(error => {
        console.error('Error fetching users:', error);
        if (ctrl.hasErrorTarget) {
          ctrl.errorTarget.textContent = 'Failed to load users. Please try again.';
          ctrl.errorTarget.style.display = 'block';
        }
      });
  `
end
```

#### `show_user`
When a user card is clicked, fetches detailed user information and posts, then dispatches an event to show the modal.

```ruby
def show_user
  `
    const userId = parseInt(event.currentTarget.getAttribute('data-user-id'));

    // Fetch user details and posts in parallel
    Promise.all([
      fetch('https://jsonplaceholder.typicode.com/users/' + userId).then(r => r.json()),
      fetch('https://jsonplaceholder.typicode.com/posts?userId=' + userId).then(r => r.json())
    ])
      .then(([user, posts]) => {
        // Dispatch event to show modal
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
```

### UserModalController

The `UserModalController` displays user details and recent posts in a modal dialog.

**Targets:**
- `overlay` - Modal background overlay
- `content` - Modal content container
- `userName`, `userEmail`, `userCompany`, etc. - User detail fields
- `postsList` - Container for user's posts

**Key Methods:**

#### `connect`
Sets up a global event listener for the `show-user-modal` event.

```ruby
def connect
  `
    const ctrl = this;

    window.addEventListener('show-user-modal', (e) => {
      const { user, posts } = e.detail;
      ctrl.displayUser(user, posts);
      ctrl.open();
    });
  `
end
```

#### `open` / `close`
Controls modal visibility and prevents background scrolling.

```ruby
def open
  `
    this.element.classList.add('active');
    this.overlayTarget.classList.add('active');
    this.contentTarget.classList.add('active');
    document.body.style.overflow = 'hidden';
  `
end

def close
  `
    this.element.classList.remove('active');
    this.overlayTarget.classList.remove('active');
    this.contentTarget.classList.remove('active');
    document.body.style.overflow = '';
  `
end
```

#### `display_user`
Populates the modal with user data and recent posts.

```ruby
private

def display_user(user, posts)
  `
    const user = arguments[0];
    const posts = arguments[1];

    // Update user info
    if (this.hasUserNameTarget) {
      this.userNameTarget.textContent = user.name;
    }
    // ... update other fields

    // Display posts (showing first 5)
    if (this.hasPostsListTarget) {
      this.postsListTarget.innerHTML = '';
      posts.slice(0, 5).forEach(post => {
        const postItem = document.createElement('div');
        postItem.className = 'post-item';
        postItem.innerHTML = \`
          <h4>\${post.title}</h4>
          <p>\${post.body}</p>
        \`;
        this.postsListTarget.appendChild(postItem);
      });
    }
  `
end
```

## Technical Concepts

### Backtick JavaScript

Opal allows inline JavaScript using backticks, which is essential for interacting with browser APIs like Fetch:

```ruby
def fetch_data
  `
    fetch('https://api.example.com/data')
      .then(response => response.json())
      .then(data => console.log(data));
  `
end
```

### Fetch API Pattern

The standard pattern for API calls:

```javascript
fetch(url)
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  })
  .then(data => {
    // Handle success
  })
  .catch(error => {
    // Handle error
  });
```

### Promise.all() for Parallel Requests

Fetch multiple endpoints simultaneously:

```javascript
Promise.all([
  fetch('/api/users/1').then(r => r.json()),
  fetch('/api/posts?userId=1').then(r => r.json())
])
  .then(([user, posts]) => {
    // Both requests are complete
  });
```

### CustomEvent for Controller Communication

Controllers can communicate using CustomEvents:

```javascript
// Dispatch event
const event = new CustomEvent('show-modal', {
  detail: { data: someData }
});
window.dispatchEvent(event);

// Listen for event
window.addEventListener('show-modal', (e) => {
  console.log(e.detail.data);
});
```

### Loading and Error States

Best practices for user feedback:

1. **Loading State**: Show immediately when request starts
2. **Success State**: Hide loading, show content
3. **Error State**: Hide loading, show error message with retry option

## Common Patterns

### 1. Controller Context in Backticks

Always capture the controller reference before backtick blocks:

```ruby
def my_method
  `
    const ctrl = this;  // Capture controller context

    fetch('/api/data')
      .then(data => {
        ctrl.updateUI(data);  // Use ctrl to access controller methods
      });
  `
end
```

### 2. Accessing Arguments in Backticks

When calling Ruby methods with arguments from JavaScript:

```ruby
def display_user(user, posts)
  `
    const user = arguments[0];    // First argument
    const posts = arguments[1];   // Second argument

    // Now use user and posts
  `
end
```

### 3. Creating DOM Elements

Efficient way to create and append elements:

```javascript
const card = document.createElement('div');
card.className = 'user-card';
card.innerHTML = `
  <h3>${user.name}</h3>
  <p>${user.email}</p>
`;
container.appendChild(card);
```

### 4. Conditional Target Rendering

Always check if targets exist before using them:

```javascript
if (ctrl.hasLoadingTarget) {
  ctrl.loadingTarget.style.display = 'block';
}
```

## Styling Techniques

This example demonstrates several CSS patterns:

- **Gradient Backgrounds**: `linear-gradient()` for modern look
- **CSS Grid**: Responsive user card layout
- **CSS Animations**: Keyframe animations for loading spinner
- **Hover Effects**: Transform and box-shadow transitions
- **Modal Overlay**: Fixed positioning with backdrop blur
- **Responsive Design**: Media queries for mobile devices

## Troubleshooting

### CORS Issues

If you encounter CORS errors when calling your own API:

1. Use a CORS proxy for development (e.g., `https://cors-anywhere.herokuapp.com/`)
2. Configure your backend to allow CORS requests
3. Use Vite's proxy feature in `vite.config.ts`:

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'https://your-api.com',
        changeOrigin: true
      }
    }
  }
})
```

### Network Errors

If requests fail:

1. Check browser console for error messages
2. Verify API endpoint is accessible
3. Ensure internet connection is active
4. Check if API has rate limiting

### Modal Not Opening

If the modal doesn't open when clicking users:

1. Check browser console for JavaScript errors
2. Verify event listeners are registered
3. Ensure targets are correctly defined in HTML
4. Check CSS classes for modal visibility

## Next Steps

Extend this example by:

1. **Add Search**: Filter users by name or email
2. **Add Pagination**: Handle large datasets efficiently
3. **Add Caching**: Store API responses in LocalStorage
4. **Add Optimistic UI**: Show changes before API confirmation
5. **Add Retry Logic**: Automatically retry failed requests
6. **Add Different APIs**: Integrate with GitHub, weather, etc.
7. **Add Charts**: Visualize user data with charts

## Resources

- [Fetch API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- [Promise.all() Reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
- [JSONPlaceholder API Guide](https://jsonplaceholder.typicode.com/guide/)
- [Opal Documentation](https://opalrb.com/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Vite Guide](https://vitejs.dev/guide/)
