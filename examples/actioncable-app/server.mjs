#!/usr/bin/env node
/**
 * Simple WebSocket server mimicking ActionCable protocol
 * For demonstration purposes only
 */

import { WebSocketServer } from 'ws';

const PORT = 3117;
const wss = new WebSocketServer({ port: PORT });

// Track connected clients and their subscriptions
const clients = new Map();
const rooms = new Map();

console.log(`ActionCable-like WebSocket server running on ws://localhost:${PORT}/cable`);

wss.on('connection', (ws) => {
  const clientId = Date.now().toString(36) + Math.random().toString(36).substr(2);
  const clientData = {
    id: clientId,
    ws,
    subscriptions: new Map(),
    username: null
  };
  clients.set(clientId, clientData);

  console.log(`Client connected: ${clientId}`);

  // Send welcome message
  send(ws, {
    type: 'welcome'
  });

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString());
      handleMessage(clientData, message);
    } catch (e) {
      console.error('Failed to parse message:', e);
    }
  });

  ws.on('close', () => {
    // Clean up subscriptions
    for (const [identifier, subscription] of clientData.subscriptions) {
      unsubscribeFromRoom(clientData, identifier);
    }
    clients.delete(clientId);
    console.log(`Client disconnected: ${clientId}`);
  });
});

function send(ws, data) {
  if (ws.readyState === 1) { // OPEN
    ws.send(JSON.stringify(data));
  }
}

function handleMessage(client, message) {
  const { command, identifier, data } = message;

  switch (command) {
    case 'subscribe':
      handleSubscribe(client, identifier);
      break;
    case 'unsubscribe':
      handleUnsubscribe(client, identifier);
      break;
    case 'message':
      handleAction(client, identifier, data);
      break;
  }
}

function handleSubscribe(client, identifier) {
  const channel = JSON.parse(identifier);
  const roomKey = `${channel.channel}:${channel.room || 'default'}`;

  // Add to room
  if (!rooms.has(roomKey)) {
    rooms.set(roomKey, new Set());
  }
  rooms.get(roomKey).add(client.id);
  client.subscriptions.set(identifier, roomKey);

  console.log(`Client ${client.id} subscribed to ${roomKey}`);

  // Confirm subscription
  send(client.ws, {
    identifier,
    type: 'confirm_subscription'
  });
}

function handleUnsubscribe(client, identifier) {
  unsubscribeFromRoom(client, identifier);
}

function unsubscribeFromRoom(client, identifier) {
  const roomKey = client.subscriptions.get(identifier);
  if (roomKey && rooms.has(roomKey)) {
    rooms.get(roomKey).delete(client.id);
    if (rooms.get(roomKey).size === 0) {
      rooms.delete(roomKey);
    }
  }
  client.subscriptions.delete(identifier);
}

function handleAction(client, identifier, dataStr) {
  const data = JSON.parse(dataStr);
  const action = data.action;
  const roomKey = client.subscriptions.get(identifier);

  if (!roomKey) return;

  switch (action) {
    case 'join':
      client.username = data.username;
      broadcastToRoom(roomKey, identifier, {
        type: 'system',
        text: `${data.username} joined the chat`
      });
      broadcastPresence(roomKey, identifier);
      break;

    case 'speak':
      broadcastToRoom(roomKey, identifier, {
        type: 'message',
        user: data.user,
        text: data.text,
        time: new Date().toISOString()
      });
      break;

    case 'typing':
      broadcastToRoom(roomKey, identifier, {
        type: 'typing',
        user: data.user
      }, client.id); // Exclude sender
      break;
  }
}

function broadcastToRoom(roomKey, identifier, message, excludeClientId = null) {
  const room = rooms.get(roomKey);
  if (!room) return;

  for (const clientId of room) {
    if (clientId === excludeClientId) continue;

    const client = clients.get(clientId);
    if (client) {
      send(client.ws, {
        identifier,
        message
      });
    }
  }
}

function broadcastPresence(roomKey, identifier) {
  const room = rooms.get(roomKey);
  if (!room) return;

  const users = [];
  for (const clientId of room) {
    const client = clients.get(clientId);
    if (client && client.username) {
      users.push(client.username);
    }
  }

  broadcastToRoom(roomKey, identifier, {
    type: 'presence',
    users
  });
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('Shutting down server...');
  wss.close();
  process.exit(0);
});
