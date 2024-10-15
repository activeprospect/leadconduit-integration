/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class HttpError extends Error {
  constructor(status, headers, body) {
    super(...arguments);
    this.status = status;
    this.headers = headers;
    this.body = body;
    this.message = 'integration terminated early';
    this.name = 'HttpError';
    Error.captureStackTrace(this);
  }
}


module.exports = HttpError;
