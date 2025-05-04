// server.js
const express = require('express');
const http = require('http');
const socketIO = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIO(server);

// Game settings
const TICK_RATE = 60;
const TICK_INTERVAL = 1000 / TICK_RATE;
const MAX_PLAYERS = 4;

// Game state
let players = {};
let currentFrame = 0;
let inputBuffer = {}; // {frame: {playerId: inputs}}
let isGameStarted = false;

io.on('connection', (socket) => {
  const playerId = socket.id;
  console.log(`Player connected: ${playerId}`);
  
  // Add player to game
  players[playerId] = {
    id: playerId,
    ready: false
  };
  
  // Client ready
  socket.on('ready', () => {
    players[playerId].ready = true;
    
    // Check if all players are ready
    let allReady = Object.values(players).every(p => p.ready);
    if (allReady && Object.keys(players).length >= 2) {
      startGame();
    }
  });
  
  // Receive inputs from client
  socket.on('input', (data) => {
    if (!isGameStarted) return;
    
    const { frame, inputs } = data;
    
    if (!inputBuffer[frame]) {
      inputBuffer[frame] = {};
    }
    
    inputBuffer[frame][playerId] = inputs;
    
    // If all players have submitted inputs for this frame, broadcast them
    if (Object.keys(inputBuffer[frame]).length === Object.keys(players).length) {
      io.emit('frame_update', { frame, inputs: inputBuffer[frame] });
    }
  });
  
  // Handle disconnection
  socket.on('disconnect', () => {
    console.log(`Player disconnected: ${playerId}`);
    delete players[playerId];
    
    if (Object.keys(players).length === 0) {
      resetGame();
    }
  });
});

function startGame() {
  isGameStarted = true;
  currentFrame = 0;
  inputBuffer = {};
  
  // Send initial game state
  io.emit('game_start', {
    players: Object.values(players),
    startFrame: currentFrame
  });
  
  // Start game loop
  setInterval(gameTick, TICK_INTERVAL);
}

function gameTick() {
  if (!isGameStarted) return;
  
  currentFrame++;
  
  // Request inputs for the next frame
  io.emit('request_input', { frame: currentFrame });
}

function resetGame() {
  isGameStarted = false;
  currentFrame = 0;
  inputBuffer = {};
}

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});