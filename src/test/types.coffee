types = require('leadconduit-types')
flat = require('flat')


module.exports.parser = (requestVars=[]) ->
  typeLookup = {}

  for requestVar in requestVars
    typeLookup[requestVar.name] = types[requestVar.type]

  (vars) ->
    parsed = {}
    for name, value of flat.flatten(vars, safe: true)
      parse = typeLookup[name]?.parse
      if parse? and value?
        parsed[name] = parse(value)
      else
        parsed[name] = value
    flat.unflatten(parsed)
