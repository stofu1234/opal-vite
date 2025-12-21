#!/usr/bin/env node
/**
 * Production server for chat-app
 * Serves static files (from dist/) and WebSocket on the same port
 * Used for Railway/production deployment
 */
import { createServer } from 'http'
import { readFileSync, existsSync } from 'fs'
import { join, extname } from 'path'
import { fileURLToPath } from 'url'
import { WebSocketServer } from 'ws'

const __dirname = fileURLToPath(new URL('.', import.meta.url))
const PORT = process.env.PORT || 3006
const DIST_DIR = join(__dirname, 'dist')

// MIME types for static files
const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
}

// WebSocket state
const clients = new Set()
const users = new Map()
let messageHistory = []
const MAX_HISTORY = 50

// Create HTTP server for static files
const server = createServer((req, res) => {
  let filePath = req.url === '/' ? '/index.html' : req.url

  // Remove query string
  filePath = filePath.split('?')[0]

  const fullPath = join(DIST_DIR, filePath)
  const ext = extname(fullPath)
  const contentType = MIME_TYPES[ext] || 'application/octet-stream'

  // Security: prevent directory traversal
  if (!fullPath.startsWith(DIST_DIR)) {
    res.writeHead(403)
    res.end('Forbidden')
    return
  }

  // Try to read file
  if (existsSync(fullPath)) {
    try {
      const content = readFileSync(fullPath)
      res.writeHead(200, { 'Content-Type': contentType })
      res.end(content)
    } catch (err) {
      res.writeHead(500)
      res.end('Internal Server Error')
    }
  } else {
    // SPA fallback - serve index.html for non-file routes
    const indexPath = join(DIST_DIR, 'index.html')
    if (existsSync(indexPath)) {
      try {
        const content = readFileSync(indexPath)
        res.writeHead(200, { 'Content-Type': 'text/html' })
        res.end(content)
      } catch (err) {
        res.writeHead(500)
        res.end('Internal Server Error')
      }
    } else {
      res.writeHead(404)
      res.end('Not Found')
    }
  }
})

// Create WebSocket server attached to HTTP server
const wss = new WebSocketServer({ server })

console.log(`Starting production server on port ${PORT}...`)

wss.on('connection', (ws) => {
  clients.add(ws)
  console.log(`New client connected. Total clients: ${clients.size}`)

  // Send message history to new client
  ws.send(JSON.stringify({
    type: 'history',
    messages: messageHistory
  }))

  // Broadcast user count
  broadcastUserCount()

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString())

      switch (message.type) {
        case 'join':
          handleJoin(ws, message)
          break
        case 'message':
          handleMessage(ws, message)
          break
        case 'typing':
          handleTyping(ws, message)
          break
        default:
          console.log('Unknown message type:', message.type)
      }
    } catch (error) {
      console.error('Error processing message:', error)
    }
  })

  ws.on('close', () => {
    const username = users.get(ws)
    clients.delete(ws)
    users.delete(ws)

    console.log(`Client disconnected. Total clients: ${clients.size}`)

    if (username) {
      const leaveMessage = {
        type: 'system',
        text: `${username} left the chat`,
        timestamp: new Date().toISOString()
      }
      broadcast(leaveMessage)
    }

    broadcastUserCount()
  })

  ws.on('error', (error) => {
    console.error('WebSocket error:', error)
  })
})

function handleJoin(ws, message) {
  const username = message.username || 'Anonymous'
  users.set(ws, username)

  const joinMessage = {
    type: 'system',
    text: `${username} joined the chat`,
    timestamp: new Date().toISOString()
  }

  broadcast(joinMessage)
  addToHistory(joinMessage)

  console.log(`${username} joined the chat`)
}

function handleMessage(ws, message) {
  const username = users.get(ws) || 'Anonymous'

  const chatMessage = {
    type: 'message',
    username: username,
    text: message.text,
    timestamp: new Date().toISOString()
  }

  broadcast(chatMessage)
  addToHistory(chatMessage)

  console.log(`${username}: ${message.text}`)
}

function handleTyping(ws, message) {
  const username = users.get(ws) || 'Anonymous'

  const typingMessage = {
    type: 'typing',
    username: username,
    isTyping: message.isTyping
  }

  // Broadcast to all clients except sender
  clients.forEach(client => {
    if (client !== ws && client.readyState === 1) {
      client.send(JSON.stringify(typingMessage))
    }
  })
}

function broadcast(message) {
  const messageStr = JSON.stringify(message)

  clients.forEach(client => {
    if (client.readyState === 1) {
      client.send(messageStr)
    }
  })
}

function broadcastUserCount() {
  const countMessage = {
    type: 'user_count',
    count: clients.size
  }

  broadcast(countMessage)
}

function addToHistory(message) {
  messageHistory.push(message)

  if (messageHistory.length > MAX_HISTORY) {
    messageHistory = messageHistory.slice(-MAX_HISTORY)
  }
}

// Start server
server.listen(PORT, () => {
  console.log(`Production server running on http://localhost:${PORT}`)
  console.log(`WebSocket available at ws://localhost:${PORT}`)
  console.log(`Serving static files from ${DIST_DIR}`)
})

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down server...')
  wss.close(() => {
    server.close(() => {
      console.log('Server closed')
      process.exit(0)
    })
  })
})

process.on('SIGTERM', () => {
  console.log('\nReceived SIGTERM, shutting down...')
  wss.close(() => {
    server.close(() => {
      console.log('Server closed')
      process.exit(0)
    })
  })
})
