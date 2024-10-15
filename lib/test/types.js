const types = require('leadconduit-types');
const flat = require('flat');

module.exports.parser = function(requestVars = []) {
  const typeLookup = {};

  for (let requestVar of requestVars) {
    typeLookup[requestVar.name] = types[requestVar.type];
  }

  return function(vars) {
    const parsed = {};
    const object = flat.flatten(vars, {safe: true});
    for (let name in object) {
      let value = object[name];
      let parse = typeLookup[name]?.parse;
      if ((parse != null) && (value != null)) {
        parsed[name] = parse(value);
      } else {
        parsed[name] = value;
      }
    }
    return flat.unflatten(parsed);
  };
};
