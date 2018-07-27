let request = require('supertest');
let app = require('../src/app');

describe('GET /', () => {
  it('should return hello world', (done) => {
    request(app)
      .get('/')
      .expect('hello world', done);
  });
});
