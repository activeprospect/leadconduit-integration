# LeadConduit Integration

A Node.JS utility module for building LeadConduit integrations.

[![Build Status](https://travis-ci.org/activeprospect/leadconduit-integration.svg?branch=master)](https://travis-ci.org/activeprospect/leadconduit-integration)

## Cake

This module provides the standard build utilities for integration modules. To use it:

1. require in your module's `package.json` (of course)
2. existing modules may have `coffee-script` and `mocha` in their `DevDependencies` - those can (probably) be removed.
3. create a file called `Cakefile` in the root of the module, with this single line:

```coffeescript
require('leadconduit-integration').cake(task)
```


### Cake Tasks

The tasks provided for the `cake` command (run `cake` to see the list, as well):

- `build` - delete and rebuild the package's `lib` directory from all `.coffee` source files in `src`
- `lint` - run `coffeelint` on `.coffee` source files in `src`
- `pdf` - generate versioned PDF files of all `.md` Markdown files in `docs`
    - These are placed in the `drive` directory, if there is one, or left in the `docs` directory, if not. If you create a symlink to a local Google Drive copy of the appropriate subfolder in the ["Integrations" folder](https://drive.google.com/drive/folders/0B36C7G4bQKsAUkl5NWFFazZXaHc), called `drive`, and you keep the Google Drive sync app running, this provides a kind of automatic uploading of doc PDFs for use by the company at large.
- `test` - run the mocha unit tests defined in `*-spec.coffee` spec files in `spec`
    - Optionally, use `-p` or `--path` to specify a prefix for the test files to run. This can be a string which prefixes the files to target (e.g., "inbound" would match just `inbound*-spec.coffee`), or with a trailing slash, a directory name (e.g., "outbound/" would match all the `*-spec.coffee` files in `spec/outbound`).


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
