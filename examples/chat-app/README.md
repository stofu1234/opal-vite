# Chat App - WebSocket Example

A real-time chat application demonstrating WebSocket integration with Opal, Stimulus, and Vite. This example shows how to build interactive, real-time applications using WebSocket for bi-directional communication.

## Features

- **Real-time Messaging**: Instant message delivery using WebSocket
- **Online User Count**: Live display of connected users
- **Typing Indicators**: See when other users are typing
- **Message History**: New users receive previous messages
- **Auto-reconnect**: Automatic reconnection on disconnect
- **XSS Protection**: HTML escaping for safe message display
- **Responsive Design**: Works on desktop and mobile devices

## Architecture

### WebSocket Server (Node.js)
- Standalone WebSocket server on port 3007
- Handles connections, messages, and broadcasts
- Maintains message history (last 50 messages)
- Supports multiple clients simultaneously

### Client (Opal + Stimulus)
- ChatController manages WebSocket connection
- Real-time UI updates using Stimulus targets
- Automatic reconnection with exponential backoff
- Clean separation of concerns

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
```

### Running the App

The app requires both the WebSocket server and the Vite dev server running simultaneously.

**Recommended: Run servers in separate terminals**

```bash
# Terminal 1 - WebSocket server
cd examples/chat-app
node server.mjs

# Terminal 2 - Vite dev server
cd examples/chat-app
pnpm client
```

**Alternative: Using pnpm scripts**

```bash
cd examples/chat-app

# Terminal 1
pnpm server

# Terminal 2
pnpm client
```

The app will be available at http://localhost:3006/

**Note**: Make sure you're in the `examples/chat-app` directory when running the commands.

## Project Structure

```
chat-app/
├── server.mjs                   # WebSocket server
├── app/
│   ├── javascript/
│   │   └── application.js       # JavaScript entry point
│   ├── opal/
│   │   ├── application.rb       # Ruby entry point
│   │   └── controllers/
│   │       └── chat_controller.rb  # Chat controller
│   └── styles.css               # Global styles
├── index.html                   # Main HTML template
├── vite.config.ts               # Vite configuration
├── package.json                 # Node.js dependencies
└── Gemfile                      # Ruby dependencies
```

## WebSocket Server

The WebSocket server (`server.mjs`) is a standalone Node.js application that:

- Listens on port 3007
- Maintains a list of connected clients
- Broadcasts messages to all connected clients
- Stores and sends message history to new users
- Handles join/leave notifications
- Manages typing indicators

### Message Types

**Client → Server:**
- `join`: User joins the chat with username
- `message`: Send a chat message
- `typing`: User is typing (or stopped typing)

**Server → Client:**
- `history`: Message history sent to new users
- `message`: Chat message from another user
- `system`: System notification (join/leave)
- `user_count`: Number of online users
- `typing`: Typing indicator from another user

### Example Messages

```javascript
// Join message
{
  type: 'join',
  username: 'Alice'
}

// Chat message
{
  type: 'message',
  text: 'Hello everyone!'
}

// Typing indicator
{
  type: 'typing',
  isTyping: true
}
```

## ChatController

The `ChatController` manages the WebSocket connection and UI updates.

### Targets
- `messages` - Container for chat messages
- `input` - Message input field
- `userCount` - Online user count display
- `typingIndicator` - Typing indicator element
- `usernameInput` - Username input field
- `chatContainer` - Main chat interface
- `loginContainer` - Login screen

### Values
- `username` - Current user's username

### Key Methods

#### `connect`
Initializes the WebSocket connection and sets up event handlers:

```ruby
def connect
  # Set up WebSocket connection
  `
    this.connectWebSocket = function() {
      const wsUrl = 'ws://localhost:3007';
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = function() {
        // Connection established
      };

      this.ws.onmessage = function(event) {
        // Handle incoming messages
      };

      this.ws.onclose = function() {
        // Reconnect on disconnect
      };
    };
  `
end
```

#### `send_message`
Sends a message to the WebSocket server:

```ruby
def send_message
  `
    const text = this.inputTarget.value.trim();

    if (text && this.isConnected) {
      this.ws.send(JSON.stringify({
        type: 'message',
        text: text
      }));

      this.inputTarget.value = '';
    }
  `
end
```

#### `handleMessage`
Processes incoming WebSocket messages and updates the UI:

```ruby
this.handleMessage = function(message) {
  switch (message.type) {
    case 'history':
      this.loadHistory(message.messages);
      break;
    case 'message':
      this.addMessage(message);
      break;
    case 'system':
      this.addSystemMessage(message);
      break;
    case 'user_count':
      this.updateUserCount(message.count);
      break;
    case 'typing':
      this.updateTypingIndicator(message);
      break;
  }
};
```

## Technical Concepts

### WebSocket API

WebSocket provides full-duplex communication between client and server:

```javascript
// Create connection
const ws = new WebSocket('ws://localhost:3007');

// Event handlers
ws.onopen = () => console.log('Connected');
ws.onmessage = (event) => console.log('Received:', event.data);
ws.onclose = () => console.log('Disconnected');
ws.onerror = (error) => console.error('Error:', error);

// Send data
ws.send(JSON.stringify({ type: 'message', text: 'Hello' }));
```

### Auto-reconnect Pattern

Automatically reconnect when the connection is lost:

```javascript
this.ws.onclose = function() {
  console.log('Disconnected');

  setTimeout(function() {
    console.log('Reconnecting...');
    ctrl.connectWebSocket();
  }, 3000);
};
```

### XSS Prevention

Always escape user input before displaying:

```javascript
this.escapeHtml = function(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
};
```

### Typing Indicators

Debounce typing events to avoid excessive updates:

```javascript
let typingTimeout = null;

// User is typing
this.ws.send(JSON.stringify({ type: 'typing', isTyping: true }));

// Clear previous timeout
if (typingTimeout) {
  clearTimeout(typingTimeout);
}

// Set timeout to send "stopped typing"
typingTimeout = setTimeout(() => {
  this.ws.send(JSON.stringify({ type: 'typing', isTyping: false }));
}, 1000);
```

## Common Patterns

### 1. Message Broadcasting

The server broadcasts messages to all connected clients:

```javascript
function broadcast(message) {
  const messageStr = JSON.stringify(message);

  clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(messageStr);
    }
  });
}
```

### 2. Selective Broadcasting

Send to all clients except the sender:

```javascript
clients.forEach(client => {
  if (client !== ws && client.readyState === WebSocket.OPEN) {
    client.send(messageStr);
  }
});
```

### 3. State Management

Track client-specific data using a Map:

```javascript
const users = new Map(); // Map<WebSocket, string>

// On join
users.set(ws, username);

// On message
const username = users.get(ws);

// On disconnect
users.delete(ws);
```

## Extending the App

Ideas for extending this chat application:

1. **Private Messages**: Add direct messaging between users
2. **Rooms/Channels**: Support multiple chat rooms
3. **File Sharing**: Upload and share images/files
4. **Message Reactions**: Add emoji reactions to messages
5. **User Authentication**: Add login/registration
6. **Persistent Storage**: Store messages in a database
7. **Rich Text**: Support markdown or rich text formatting
8. **Read Receipts**: Show when messages are read
9. **User Presence**: Show online/offline/away status
10. **Message Search**: Search through message history

## Troubleshooting

### WebSocket Connection Fails

If you can't connect to the WebSocket server:

1. Ensure the server is running on port 3007:
   ```bash
   pnpm server
   ```

2. Check the browser console for connection errors

3. Verify the WebSocket URL in `chat_controller.rb`:
   ```ruby
   const wsUrl = 'ws://localhost:3007';
   ```

### Messages Not Appearing

If messages aren't displaying:

1. Check browser console for JavaScript errors
2. Verify the WebSocket connection is established
3. Check server logs for incoming messages
4. Ensure targets are correctly defined in HTML

### Auto-reconnect Not Working

If reconnection fails:

1. Check the reconnection timeout in `chat_controller.rb`
2. Verify the server is accepting new connections
3. Check for errors in the browser console

## Resources

- [WebSocket API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [ws Library (Node.js)](https://github.com/websockets/ws)
- [Opal Documentation](https://opalrb.com/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Vite Guide](https://vitejs.dev/guide/)

## Performance Considerations

- **Message Size**: Keep messages small for better performance
- **Connection Limits**: Consider scaling for many concurrent users
- **Message History**: Limit history size to prevent memory issues
- **Reconnection**: Use exponential backoff to avoid overwhelming the server
- **Security**: Always validate and sanitize user input on the server
