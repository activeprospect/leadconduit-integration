humanname = require 'humanname'
mimeparse = require 'mimeparse'
HttpError = require './http-error'

selectMimeType = (contentType, supportedTypes) ->
  return unless contentType?
  mimeparse.bestMatch(supportedTypes, contentType)

module.exports =

  # given a string containing a person's full name, return a two-element array containing firstName and lastName
  parseFullname: (fullname) ->
    parsed = humanname.parse(fullname)

    salutation: parsed.salutation
    first_name: parsed.firstName
    middle_name: parsed.initials
    last_name: parsed.lastName
    suffix: parsed.suffix


  validateRequest: (req, mimeTypes, methods) ->

    #ensure supported method
    method = req.method?.toLowerCase()
    supportedMethods = methods or ['POST']
    supportedMethods = supportedMethods.map (val) -> val.toLowerCase()
    unless supportedMethods.indexOf(method) > -1
      throw new HttpError(415, { 'Content-Type': 'text/plain', Allow: 'POST' }, "The #{method.toUpperCase()} method is not allowed")

    #ensure a content-type header
    contentType = req.headers['Content-Type']
    unless contentType
      throw new HttpError(415, { 'Content-Type': 'text/plain' }, 'Content-Type header is required')

    #ensure a valid mime type
    unless mimeTypes.indexOf(selectMimeType(req.headers['Content-Type'], mimeTypes)) > -1
      throw new HttpError(415, {'Content-Type': 'text/plain'}, "MIME type in Content-Type header is not supported. Use only #{mimeTypes.join ', '}")


  # given a starting timestamp and the total timeout (in ms), return the remaining timeout (in ms)
  calculateTimeout: (startTimestamp, timeoutMs) ->
    elapsedMs = new Date().getTime() - startTimestamp
    remaining = timeoutMs - elapsedMs
    return 1 if remaining <= 0 # the `request` library treats a timeout value of '0' as no timeout
    remaining
