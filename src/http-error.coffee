class HttpError extends Error
  constructor: (@status, @headers, @body) ->
    @message = 'integration terminated early'
    @name = 'HttpError'
    Error.captureStackTrace @, arguments.callee
    super


module.exports = HttpError
#HttpError = (status, headers, body) ->


#  Error.call(@)
#  Error.captureStackTrace(@, arguments.callee)
#  @status = status
#  @headers = headers
#  @body = body
#  @name = 'HttpError'
#
#HttpError.prototype.__proto__ = Error.prototype;