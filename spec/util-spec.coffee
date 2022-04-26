assert = require('chai').assert
utils = require('../src/util')

describe 'Utility functions', ->

  describe 'parseFullname', ->

    it 'should parse a standard name', ->
      parsed = utils.parseFullname("John Smith")
      assert.equal parsed.first_name, "John"
      assert.equal parsed.last_name, "Smith"

    it 'should parse a name with an apostrophe', ->
      parsed = utils.parseFullname("Sean O'Reilly")
      assert.equal parsed.first_name, "Sean"
      assert.equal parsed.last_name, "O'Reilly"

    it 'should parse a name with a space', ->
      parsed = utils.parseFullname("Juliana de Luna")
      assert.equal parsed.first_name, "Juliana"
      assert.equal parsed.last_name, "de Luna"

    it 'should parse a name with a bunch of other stuff', ->
      parsed = utils.parseFullname("Mr. Charles P. Wooten, III")
      assert.equal parsed.salutation, "Mr."
      assert.equal parsed.first_name, "Charles"
      assert.equal parsed.middle_name, "P."
      assert.equal parsed.last_name, "Wooten"
      assert.equal parsed.suffix, "III"

  describe 'validateRequest', ->

    it 'should not error if all required data is correct', ->
      invokeRequest = ->
        utils.validateRequest({method: 'POST', headers: {'Content-Type': 'application/json'}}, ['application/json'])
      try
       invokeRequest()
      catch err
      finally
        assert.isUndefined err

    it 'should error if method is not POST', ->
      invokeRequest = ->
        utils.validateRequest({method: 'GET', headers: {'Content-Type': 'application/json'}}, ['application/json'])
      try
        invokeRequest()
      catch err
        assert.equal err.status, 415
        assert.equal err.body, 'The GET method is not allowed'
      finally
        assert.isDefined err

    it 'should require a Content-Type header', ->
      invokeRequest = ->
        utils.validateRequest({method: 'POST', headers: {}}, ['application/json'])
      try
        invokeRequest()
      catch err
        assert.equal err.status, 415
        assert.equal err.body, 'Content-Type header is required'
      finally
        assert.isDefined err

    it 'should require the correct Content-Type header', ->
      invokeRequest = ->
        utils.validateRequest({method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}}, ['application/json'])
      try
        invokeRequest()
      catch err
        assert.equal err.status, 415
        assert.equal err.body, 'MIME type in Content-Type header is not supported. Use only application/json'
      finally
        assert.isDefined err

    it 'should support allowing multiple Content-Types', ->
      invokeRequest = (contentType) ->
        utils.validateRequest({method: 'POST', headers: {'Content-Type': contentType}}, ['application/json', 'application/xml'])
      try
        invokeRequest('application/json')
        invokeRequest('application/xml')
      catch err
      finally
        assert.isUndefined err

    it 'should support allowing multiple methods', ->
      invokeRequest = (method) ->
        utils.validateRequest({method: method, headers: {'Content-Type': 'text/json'}}, ['text/json'], ['GET', 'POST'])
      try
        invokeRequest('GET')
        invokeRequest('POST')
      catch err
      finally
        assert.isUndefined err


  describe 'calculateTimeout', ->

    it 'returns the correct remaining timeout', ->
      timeout = -1
      start = new Date(new Date().getTime() - 2000) # 2s ago
      timeout = utils.calculateTimeout(start, 4000) # 4s timeout
      assert.closeTo timeout, 2000, 500 # .5s of wiggle-room


    it 'returns minimum of zero', ->
      timeout = -1
      start = new Date(new Date().getTime() - 2000) # 2s ago
      timeout = utils.calculateTimeout(start, 1000) # 1s timeout
      assert.equal timeout, 1

  describe.only 'mask', ->

    transactions = []
    beforeEach ->
      transactions = [
        {
          request: {
            uri: 'https://test.anura.com',
            body: 'instance=testInstanceKey&ip=192.168.255.255&source=sourceKey'
          },
          response: {status: 200, status_text: 'OK', body: '{"outcome":"success","id":"12345"}'}
        },
        {
          request: {
            uri: 'https://test2.anura.com',
            body: 'instance2=testInstanceKey&ip=192.168.255.255&source=sourceKey'
          },
          response: {status: 200, status_text: 'OK', body: '{"outcome":"success","id":"12345"}'}
        }
      ]

    it 'masks one value in each transaction, using the default path', ->
      utils.mask(transactions, 'testInstanceKey');
      assert.equal(transactions[0].request.body, 'instance=***********&ip=192.168.255.255&source=sourceKey');
      assert.equal(transactions[1].request.body, 'instance2=***********&ip=192.168.255.255&source=sourceKey');

    it 'masks one value in only one transaction, using a custom path', ->
      utils.mask(transactions, 'testInstanceKey', '0.request.body');
      assert.equal(transactions[0].request.body, 'instance=***********&ip=192.168.255.255&source=sourceKey');
      assert.equal(transactions[1].request.body, 'instance2=testInstanceKey&ip=192.168.255.255&source=sourceKey');

    it 'masks one value in each transaction, using a custom path', ->
      utils.mask(transactions, 'test', 'request.uri');
      assert.equal(transactions[0].request.uri, 'https://***********.anura.com');
      assert.equal(transactions[1].request.uri, 'https://***********2.anura.com');

    it 'masks one value in each transaction, with multiple occurrences', ->
      utils.mask(transactions, 'source');
      assert.equal(transactions[0].request.body, 'instance=testInstanceKey&ip=192.168.255.255&***********=***********Key');
      assert.equal(transactions[1].request.body, 'instance2=testInstanceKey&ip=192.168.255.255&***********=***********Key');

    xit 'masks multiple values...', ->
      utils.mask(transactions, 'source');
      assert.equal(transactions[0].request.body, 'instance=testInstanceKey&ip=192.168.255.255&***********=***********Key');

    xit 'masks only specific path values...', ->
      utils.mask(transactions, 'source');
      assert.equal(transactions[0].request.body, 'instance=testInstanceKey&ip=192.168.255.255&***********=***********Key');
