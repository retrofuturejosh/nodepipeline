let app = require('../src');
let expect = require('chai').expect;

describe('App', () => {
  it('should have the correct string', () => {
    expect(app).to.equal('This is an app.');
  });
});
