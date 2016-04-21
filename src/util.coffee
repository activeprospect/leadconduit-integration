humanname = require 'humanname'
mimeparse = require 'mimeparse'
HttpError = require './http-error'

# given a string containing a person's full name, return a two-element array containing firstName and lastName
parseFullname = (fullname) ->
  parsed = humanname.parse(fullname)

  salutation: parsed.salutation
  first_name: parsed.firstName
  middle_name: parsed.initials
  last_name: parsed.lastName
  suffix: parsed.suffix

validateRequest = (req, mimeTypes) ->

  #ensure supported method
  method = req.method?.toLowerCase()
  if method isnt 'post'
    throw new HttpError(415, { 'Content-Type': 'text/plain', Allow: 'POST' }, "The #{method.toUpperCase()} method is not allowed")

  #ensure a content-type header
  contentType = req.headers['Content-Type']
  unless contentType
    throw new HttpError(415, { 'Content-Type': 'text/plain' }, 'Content-Type header is required')

  #ensure a valid mime type
  unless mimeTypes.indexOf(selectMimeType(req.headers['Content-Type'], mimeTypes)) > -1
    throw new HttpError(415, {'Content-Type': 'text/plain'}, "MIME type in Content-Type header is not supported. Use only #{mimeTypes.join ', '}")

selectMimeType = (contentType, supportedTypes) ->
  contentType = contentType or 'text/xml'
  contentType = 'text/xml' if contentType == '*/*'
  mimeparse.bestMatch(supportedTypes, contentType)

module.exports =
  parseFullname: parseFullname
  validateRequest: validateRequest
