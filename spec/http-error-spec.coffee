assert = require('chai').assert
HttpError = require('../src/http-error')


describe 'HttpError', ->

  it 'should capture stack trace', ->
    fxn = ->
      throw new HttpError(500, {}, '')
    try
      fxn()
      assert.fail()
    catch e
      stack = e.stack.split('\n')
      assert.equal stack[0], 'HttpError: integration terminated early'
      assert.match stack[1], /spec\/http\-error\-spec\.coffee\:9\:17\)$/

  it 'should have name', ->
    assert.equal new HttpError(500, {}, '').name, 'HttpError'

  it 'should be an instance of HttpError', ->
    assert new HttpError() instanceof HttpError
