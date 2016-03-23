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
