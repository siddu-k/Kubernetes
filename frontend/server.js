const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = 3000;
const API_URL = process.env.API_URL || 'http://backend:5000'; 

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
// Home page
app.get('/', (req, res) => {
  res.render('index');
});

// Get data from Flask API
app.get('/get-data', async (req, res) => {
  try {
    const response = await axios.get(`${API_URL}/api/data`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching data:', error.message);
    res.status(500).json({ error: 'Failed to fetch data from API' });
  }
});

// Get greeting message from Flask API
app.get('/greet/:name', async (req, res) => {
  try {
    const response = await axios.get(`${API_URL}/api/message/${req.params.name}`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching message:', error.message);
    res.status(500).json({ error: 'Failed to fetch message from API' });
  }
});

app.listen(PORT, () => {
  console.log(`Express server running on http://localhost:${PORT}`);
  console.log(`Flask API expected at http://localhost:5000`);
});
