const express = require('express');
const app = express();
const PORT = 3000;

// Add CORS and JSON middleware
app.use(express.json());

// Define protected routes
app.get('/', (req, res) => {
  // Get username from X-User header (set by nginx after successful auth)
  const username = req.headers['x-user'] || 'anonymous';
  res.json({
    message: `Hello ${username}! This is a protected Express.js service.`,
    timestamp: new Date().toISOString()
  });
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Express service running on port ${PORT}`);
});