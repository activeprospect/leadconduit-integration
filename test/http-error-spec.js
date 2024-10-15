const { assert } = require('chai');
const HttpError = require('../lib/http-error');

describe('HttpError', function() {

  it('should capture stack trace', function() {
    const fxn = function() {
      throw new HttpError(500, {}, '');
    };
    try {
      fxn();
      return assert.fail();
    } catch (e) {
      const stack = e.stack.split('\n');
      assert.equal(stack[0], 'HttpError: integration terminated early');
      assert.match(stack[2], /at fxn.*test\/http\-error\-spec\.js\:/);
    }
  });

  it('should have name', () => assert.equal(new HttpError(500, {}, '').name, 'HttpError'));

  it('should be an instance of HttpError', () => assert(new HttpError() instanceof HttpError));
});
