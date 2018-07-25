let express = require('express');
let app = express();

app.get('/', (req, res) => {
  res.send('Hello world!');
});

module.exports = app;
