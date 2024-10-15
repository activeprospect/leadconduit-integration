const { assert } = require('chai');
const { parser } = require('../lib/test/types');

describe('Test types parse', function() {

  it('should parse number to string', function() {
    const parse = parser([ {name: 'foo', type: 'string'} ]);
    assert.deepEqual(parse({foo: 5}), {foo: '5'});
  });

  it('should parse to typed value', function() {
    const parse = parser([ {name: 'foo', type: 'number'} ]);
    const parsed = parse({foo: '5'});
    assert.equal(parsed.foo.valueOf(), 5);
    assert.equal(parsed.foo.raw, '5');
    assert.isTrue(parsed.foo.valid);
  });

  it('should do nothing if request variable is missing a type', function() {
    const parse =  parser([ {name: 'foo'} ]);
    assert.deepEqual(parse({foo: 5}), {foo: 5});
  });

  it('should do nothing if request variable is missing', function() {
    const parse = parser([]);
    assert.deepEqual(parse({foo: 5}), {foo: 5});
  });
});
