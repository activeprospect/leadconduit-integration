const humanname = require('humanname');
const mimeparse = require('mimeparse');
const HttpError = require('../lib/http-error');
const stripMetadata = require('../lib/strip-metadata');

const selectMimeType = function(contentType, supportedTypes) {
  if (contentType == null) { return; }
  return mimeparse.bestMatch(supportedTypes, contentType);
};

module.exports = {

  // given a string containing a person's full name, return a two-element array containing firstName and lastName
  parseFullname(fullname) {
    let parsed;

    try {
      parsed = humanname.parse(fullname);
    } catch (e) {
      parsed = { firstName: fullname };
    }

    return {
      salutation: parsed.salutation,
      first_name: parsed.firstName,
      middle_name: parsed.initials,
      last_name: parsed.lastName,
      suffix: parsed.suffix
    };
  },

  validateRequest(req, mimeTypes, methods) {

    //ensure supported method
    const method = req.method?.toLowerCase();
    let supportedMethods = methods || ['POST'];
    supportedMethods = supportedMethods.map(val => val.toLowerCase());
    if (!(supportedMethods.indexOf(method) > -1)) {
      throw new HttpError(415, { 'Content-Type': 'text/plain', Allow: 'POST' }, `The ${method.toUpperCase()} method is not allowed`);
    }

    //ensure a content-type header
    const contentType = req.headers['Content-Type'];
    if (!contentType) {
      throw new HttpError(415, { 'Content-Type': 'text/plain' }, 'Content-Type header is required');
    }

    //ensure a valid mime type
    if (!(mimeTypes.indexOf(selectMimeType(req.headers['Content-Type'], mimeTypes)) > -1)) {
      throw new HttpError(415, {'Content-Type': 'text/plain'}, `MIME type in Content-Type header is not supported. Use only ${mimeTypes.join(', ')}`);
    }
  },

  // given a starting timestamp and the total timeout (in ms), return the remaining timeout (in ms)
  calculateTimeout(startTimestamp, timeoutMs) {
    const elapsedMs = new Date().getTime() - startTimestamp;
    const remaining = timeoutMs - elapsedMs;
    if (remaining <= 0) { return 1; } // the `request` library treats a timeout value of '0' as no timeout
    return remaining;
  },

  stripMetadata,

  getBaseUrl(env) {
    if (env == null) { env = process.env.NODE_ENV; }
    switch (env) {
      case 'staging': return 'https://app.leadconduit-staging.com';
      case 'development': return 'https://app.leadconduit-development.com';
      case 'local': return 'http://leadconduit.localhost';
      default: return 'https://app.leadconduit.com';
    }
  }
};
