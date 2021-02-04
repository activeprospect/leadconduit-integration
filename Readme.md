# LeadConduit Integration

A Node.JS utility module for use in LeadConduit integrations.

[![Build Status](https://github.com/activeprospect/leadconduit-integration/workflows/Node.js%20CI/badge.svg)](https://github.com/activeprospect/leadconduit-integration/actions)

## HttpError

When building inbound integrations, you can throw an HttpError in your request function if you want to stop processing 
the request and respond back to the caller immediately.

The HttpError constructor takes three parameters:

* `status` &mdash; the HTTP status code to return
* `headers` &mdash; an object containing the HTTP headers
* `body` &mdash; a string containing the response body to return

#### Example

```coffeescript
HttpError = require('leadconduit-integration').HttpError

request = (req) ->

  # ensure supported method
  method = req.method?.toLowerCase()
  if method != 'get' and method != 'post'
    throw new HttpError(415, { 'Content-Type': 'text/plain', Allow: 'GET, POST' }, "The #{method.toUpperCase()} method is not allowed")

  # ... carry on with the request function
```


## Test Helper

Use the type parser when building tests to simulate the data that LeadConduit will pass to your outbound integration.

Given an array of request vars, each with a `name` and `type` property, the parser will return a function to
parse a variables object into richly typed properties. If a request variable isn't provided or if the type cannot
be resolved, then the variable is left untouched.

#### Example

```coffeescript
parser = require('leadconduit-integration').test.parser

requestVars = [
  { name: 'zip', type: 'postal_code' }
  { name: 'home_phone', type: 'phone' }
]

parse = parser(requestVars)

parse(name: 'Alex', zip: '78704', home_phone: '5127891121')

# => { name: 'Alex',
#      zip:
#        { [String: '78704']
#          raw: '78704',
#          country_code: 'US',
#          code: '78704',
#          zip: '78704',
#          four: null,
#          valid: true },
#      home_phone:
#        { [String: '5127891121']
#          prefix: '1',
#          raw: '5127891121',
#          area: '512',
#          exchange: '789',
#          line: '1121',
#          number: '7891121',
#          extension: null,
#          country_code: 'US',
#          type: null,
#          valid: true } }
```
