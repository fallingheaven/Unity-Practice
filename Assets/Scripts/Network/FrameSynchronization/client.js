// client.js
const io = require('socket.io-client');
const socket = io('http://localhost:3000');

// Game state
let playerId;
let players = {};
let currentFrame = 0;
let pendingFrames = [];
let gameState = {}; // Will hold the synchronized game state

// Connect to server
socket.on('connect', () => {
  playerId = socket.id;
  console.log(`Connected as player: ${playerId}`);
  
  // Tell server we're ready
  socket.emit('ready');
});

// Game start event
socket.on('game_start', (data) => {
  players = data.players;
  currentFrame = data.startFrame;
  console.log('Game started!');
  
  // Start game loop
  setInterval(clientGameLoop, 16); // ~60fps
});

// Server requests input for a frame
socket.on('request_input', (data) => {
  const { frame } = data;
  
  // Gather input for the current frame
  const inputs = gatherPlayerInput();
  
  // Send inputs to server
  socket.emit('input', { frame, inputs });
});

// Server broadcasts frame updates
socket.on('frame_update', (data) => {
  const { frame, inputs } = data;
  
  // Store the frame for processing
  pendingFrames.push({ frame, inputs });
  
  // Sort frames to ensure correct order
  pendingFrames.sort((a, b) => a.frame - b.frame);
});

function clientGameLoop() {
  // Process any pending frames
  while (pendingFrames.length > 0 && pendingFrames[0].frame === currentFrame + 1) {
    const frameData = pendingFrames.shift();
    processFrame(frameData.frame, frameData.inputs);
    currentFrame = frameData.frame;
  }
  
  // Render game state
  renderGame();
}

function gatherPlayerInput() {
  // Example: Get keyboard input
  return {
    up: isKeyPressed('ArrowUp'),
    down: isKeyPressed('ArrowDown'),
    left: isKeyPressed('ArrowLeft'),
    right: isKeyPressed('ArrowRight'),
    action: isKeyPressed('Space')
  };
}

function processFrame(frame, allInputs) {
  // Process all players' inputs in the same order
  for (const playerId in allInputs) {
    const playerInput = allInputs[playerId];
    updatePlayerState(playerId, playerInput);
  }
  
  // Update game physics, collisions, etc.
  updateGamePhysics();
}

function updatePlayerState(id, input) {
  // Update player position based on input
  const player = gameState.players[id];
  if (!player) return;
  
  if (input.up) player.y -= player.speed;
  if (input.down) player.y += player.speed;
  if (input.left) player.x -= player.speed;
  if (input.right) player.x += player.speed;
  // Process other inputs...
}

// Other necessary game functions
function updateGamePhysics() { /* ... */ }
function renderGame() { /* ... */ }
function isKeyPressed(key) { /* ... */ }