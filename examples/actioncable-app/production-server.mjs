#!/usr/bin/env node
/**
 * Production server for actioncable-app
 * Serves static files (from dist/) and ActionCable-compatible WebSocket on the same port
 * Used for Railway/production deployment
 */
import { createServer } from 'http'
import { readFileSync, existsSync } from 'fs'
import { join, extname } from 'path'
import { fileURLToPath } from 'url'
import { WebSocketServer } from 'ws'

const __dirname = fileURLToPath(new URL('.', import.meta.url))
const PORT = process.env.PORT || 3017
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

// ActionCable state
const clients = new Map()
const rooms = new Map()

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

console.log(`Starting ActionCable production server on port ${PORT}...`)

// ActionCable protocol handlers
wss.on('connection', (ws) => {
  const clientId = Date.now().toString(36) + Math.random().toString(36).substr(2)
  const clientData = {
    id: clientId,
    ws,
    subscriptions: new Map(),
    username: null
  }
  clients.set(clientId, clientData)

  console.log(`Client connected: ${clientId}. Total clients: ${clients.size}`)

  // Send welcome message (ActionCable protocol)
  send(ws, { type: 'welcome' })

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString())
      handleMessage(clientData, message)
    } catch (e) {
      console.error('Failed to parse message:', e)
    }
  })

  ws.on('close', () => {
    // Broadcast leave message if user was in a room
    if (clientData.username) {
      for (const [identifier, roomKey] of clientData.subscriptions) {
        broadcastToRoom(roomKey, identifier, {
          type: 'system',
          text: `${clientData.username} left the chat`
        })
        broadcastPresence(roomKey, identifier)
      }
    }

    // Clean up subscriptions
    for (const [identifier] of clientData.subscriptions) {
      unsubscribeFromRoom(clientData, identifier)
    }
    clients.delete(clientId)
    console.log(`Client disconnected: ${clientId}. Total clients: ${clients.size}`)
  })

  ws.on('error', (error) => {
    console.error('WebSocket error:', error)
  })
})

function send(ws, data) {
  if (ws.readyState === 1) { // OPEN
    ws.send(JSON.stringify(data))
  }
}

function handleMessage(client, message) {
  const { command, identifier, data } = message

  switch (command) {
    case 'subscribe':
      handleSubscribe(client, identifier)
      break
    case 'unsubscribe':
      handleUnsubscribe(client, identifier)
      break
    case 'message':
      handleAction(client, identifier, data)
      break
  }
}

function handleSubscribe(client, identifier) {
  const channel = JSON.parse(identifier)
  const roomKey = `${channel.channel}:${channel.room || 'default'}`

  // Add to room
  if (!rooms.has(roomKey)) {
    rooms.set(roomKey, new Set())
  }
  rooms.get(roomKey).add(client.id)
  client.subscriptions.set(identifier, roomKey)

  console.log(`Client ${client.id} subscribed to ${roomKey}`)

  // Confirm subscription (ActionCable protocol)
  send(client.ws, {
    identifier,
    type: 'confirm_subscription'
  })
}

function handleUnsubscribe(client, identifier) {
  unsubscribeFromRoom(client, identifier)
}

function unsubscribeFromRoom(client, identifier) {
  const roomKey = client.subscriptions.get(identifier)
  if (roomKey && rooms.has(roomKey)) {
    rooms.get(roomKey).delete(client.id)
    if (rooms.get(roomKey).size === 0) {
      rooms.delete(roomKey)
    }
  }
  client.subscriptions.delete(identifier)
}

function handleAction(client, identifier, dataStr) {
  const data = JSON.parse(dataStr)
  const action = data.action
  const roomKey = client.subscriptions.get(identifier)

  if (!roomKey) return

  switch (action) {
    case 'join':
      client.username = data.username
      broadcastToRoom(roomKey, identifier, {
        type: 'system',
        text: `${data.username} joined the chat`
      })
      broadcastPresence(roomKey, identifier)
      console.log(`${data.username} joined ${roomKey}`)
      break

    case 'speak':
      broadcastToRoom(roomKey, identifier, {
        type: 'message',
        user: data.user,
        text: data.text,
        time: new Date().toISOString()
      })
      console.log(`${data.user}: ${data.text}`)
      break

    case 'typing':
      broadcastToRoom(roomKey, identifier, {
        type: 'typing',
        user: data.user
      }, client.id) // Exclude sender
      break
  }
}

function broadcastToRoom(roomKey, identifier, message, excludeClientId = null) {
  const room = rooms.get(roomKey)
  if (!room) return

  for (const clientId of room) {
    if (clientId === excludeClientId) continue

    const client = clients.get(clientId)
    if (client) {
      send(client.ws, {
        identifier,
        message
      })
    }
  }
}

function broadcastPresence(roomKey, identifier) {
  const room = rooms.get(roomKey)
  if (!room) return

  const users = []
  for (const clientId of room) {
    const client = clients.get(clientId)
    if (client && client.username) {
      users.push(client.username)
    }
  }

  broadcastToRoom(roomKey, identifier, {
    type: 'presence',
    users
  })
}

// Start server
server.listen(PORT, () => {
  console.log(`Production server running on http://localhost:${PORT}`)
  console.log(`ActionCable WebSocket available at ws://localhost:${PORT}/cable`)
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
