const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello Frogs! \n ');
});

server.listen(port, hostname, () => {
  console.log(`Hello Frog 🐸 - Server running at http://${hostname}:${port}/`);
});
