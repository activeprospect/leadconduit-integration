assert = require('chai').assert
utils = require('../src/util')

describe 'Utility functions', ->

  describe 'parseFullname', ->

    it 'should parse a standard name', ->
      [firstName, lastName] = utils.parseFullname("John Smith")
      assert.equal firstName, "John"
      assert.equal lastName, "Smith"

    it 'should parse a name with an apostrophe', ->
      [firstName, lastName] = utils.parseFullname("Sean O'Reilly")
      assert.equal firstName, "Sean"
      assert.equal lastName, "O'Reilly"

    it 'should parse a name with a space', ->
      [firstName, lastName] = utils.parseFullname("Juliana de Luna")
      assert.equal firstName, "Juliana"
      assert.equal lastName, "de Luna"

    it 'should parse a name with a bunch of other stuff', ->
      [firstName, lastName] = utils.parseFullname("Mr. Charles P. Wooten, III")
      assert.equal firstName, "Charles"
      assert.equal lastName, "Wooten"

