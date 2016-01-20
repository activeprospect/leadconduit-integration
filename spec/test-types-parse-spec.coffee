assert = require('chai').assert
parser = require('../src/test/types').parser


describe 'Test types parse', ->

  it 'should parse number to string', ->
    parse = parser([ name: 'foo', type: 'string' ])
    assert.deepEqual parse(foo: 5), foo: '5'

  it 'should parse to typed value', ->
    parse = parser([ name: 'foo', type: 'number' ])
    parsed = parse(foo: '5')
    assert.equal parsed.foo.valueOf(), 5
    assert.equal parsed.foo.raw, '5'
    assert.isTrue parsed.foo.valid

  it 'should do nothing if request variable is missing a type', ->
    parse =  parser([ name: 'foo' ])
    assert.deepEqual parse(foo: 5), foo: 5

  it 'should do nothing if request variable is missing', ->
    parse = parser([])
    assert.deepEqual parse(foo: 5), foo: 5
