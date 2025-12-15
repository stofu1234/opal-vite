#!/usr/bin/env node
import { WebSocketServer } from 'ws'

const PORT = 3007
const wss = new WebSocketServer({ port: PORT })

// Store connected clients
const clients = new Set()
const users = new Map() // Map client to username
let messageHistory = []
const MAX_HISTORY = 50

console.log(`🚀 WebSocket server running on ws://localhost:${PORT}`)

wss.on('connection', (ws) => {
  clients.add(ws)
  console.log(`👤 New client connected. Total clients: ${clients.size}`)

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

    console.log(`👋 Client disconnected. Total clients: ${clients.size}`)

    if (username) {
      // Broadcast leave message
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

  console.log(`👤 ${username} joined the chat`)
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

  console.log(`💬 ${username}: ${message.text}`)
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
    if (client.readyState === 1) { // OPEN
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

  // Keep only last MAX_HISTORY messages
  if (messageHistory.length > MAX_HISTORY) {
    messageHistory = messageHistory.slice(-MAX_HISTORY)
  }
}

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down WebSocket server...')
  wss.close(() => {
    console.log('✅ Server closed')
    process.exit(0)
  })
})
