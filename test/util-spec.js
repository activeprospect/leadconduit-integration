const { assert } = require('chai');
const utils = require('../lib/util');

describe('Utility functions', function() {

  describe('parseFullname', function() {

    it('should parse a standard name', function() {
      const parsed = utils.parseFullname("John Smith");
      assert.equal(parsed.first_name, "John");
      assert.equal(parsed.last_name, "Smith");
    });

    it('should parse a name with an apostrophe', function() {
      const parsed = utils.parseFullname("Sean O'Reilly");
      assert.equal(parsed.first_name, "Sean");
      assert.equal(parsed.last_name, "O'Reilly");
    });

    it('should parse a name with a space', function() {
      const parsed = utils.parseFullname("Juliana de Luna");
      assert.equal(parsed.first_name, "Juliana");
      assert.equal(parsed.last_name, "de Luna");
    });

    it('should parse a name with a bunch of other stuff', function() {
      const parsed = utils.parseFullname("Mr. Charles P. Wooten, III");
      assert.equal(parsed.salutation, "Mr.");
      assert.equal(parsed.first_name, "Charles");
      assert.equal(parsed.middle_name, "P.");
      assert.equal(parsed.last_name, "Wooten");
      assert.equal(parsed.suffix, "III");
    });

    it('should handle parser errors by defaulting to only setting first name', function () {
      const parsed = utils.parseFullname('Foo(Bar)');
      assert.equal(parsed.first_name, 'Foo(Bar)');
    });
  });

  describe('validateRequest', function() {

    it('should not error if all required data is correct', function() {
      let err;
      const invokeRequest = () => utils.validateRequest({method: 'POST', headers: {'Content-Type': 'application/json'}}, ['application/json']);
      try {
       invokeRequest();
      } catch (error) {
        err = error;
      }
      finally {
        assert.isUndefined(err);
      }
    });

    it('should error if method is not POST', function() {
      let err;
      const invokeRequest = () => utils.validateRequest({method: 'GET', headers: {'Content-Type': 'application/json'}}, ['application/json']);
      try {
        invokeRequest();
      } catch (error) {
        err = error;
        assert.equal(err.status, 415);
        assert.equal(err.body, 'The GET method is not allowed');
      }
      finally {
        assert.isDefined(err);
      }
    });

    it('should require a Content-Type header', function() {
      let err;
      const invokeRequest = () => utils.validateRequest({method: 'POST', headers: {}}, ['application/json']);
      try {
        invokeRequest();
      } catch (error) {
        err = error;
        assert.equal(err.status, 415);
        assert.equal(err.body, 'Content-Type header is required');
      }
      finally {
        assert.isDefined(err);
      }
    });

    it('should require the correct Content-Type header', function() {
      let err;
      const invokeRequest = () => utils.validateRequest({method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}}, ['application/json']);
      try {
        invokeRequest();
      } catch (error) {
        err = error;
        assert.equal(err.status, 415);
        assert.equal(err.body, 'MIME type in Content-Type header is not supported. Use only application/json');
      }
      finally {
        assert.isDefined(err);
      }
    });

    it('should support allowing multiple Content-Types', function() {
      let err;
      const invokeRequest = contentType => utils.validateRequest({method: 'POST', headers: {'Content-Type': contentType}}, ['application/json', 'application/xml']);
      try {
        invokeRequest('application/json');
        invokeRequest('application/xml');
      } catch (error) {
        err = error;
      }
      finally {
        assert.isUndefined(err);
      }
    });

    it('should support allowing multiple methods', function() {
      let err;
      const invokeRequest = method => utils.validateRequest({method, headers: {'Content-Type': 'text/json'}}, ['text/json'], ['GET', 'POST']);
      try {
        invokeRequest('GET');
        invokeRequest('POST');
      } catch (error) {
        err = error;
      }
      finally {
        assert.isUndefined(err);
      }
    });
  });


  describe('calculateTimeout', function() {

    it('returns the correct remaining timeout', function() {
      let timeout = -1;
      const start = new Date(new Date().getTime() - 2000); // 2s ago
      timeout = utils.calculateTimeout(start, 4000); // 4s timeout
      assert.closeTo(timeout, 2000, 500);
    }); // .5s of wiggle-room


    it('returns minimum of zero', function() {
      let timeout = -1;
      const start = new Date(new Date().getTime() - 2000); // 2s ago
      timeout = utils.calculateTimeout(start, 1000); // 1s timeout
      assert.equal(timeout, 1);
    });
  });
});
