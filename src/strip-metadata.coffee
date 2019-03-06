_ = require('lodash')
flat = require('flat')

excludePatterns = [
  /^timestamp$/
  /^timeout_seconds$/
  /^random$/
  /^flow\./
  /^source\./
  /^account\./
  /^lead\.id/
  /^recipient\./
  /^submission\./
  /\.outcome$/
  /\.reason$/
  /\.billable$/
]

# given the `vars` "snowball", this will strip all the data that a user
# wouldn't want delivered as a "lead". used, for example, by email-delivery
module.exports = (vars, additionalExcludes = []) ->

  for exclude in additionalExcludes
    # \b = word-boundary, so, e.g., "cc" doesn't exclude "accept"
    excludePatterns.push(if _.isRegExp(exclude) then exclude else RegExp("\\b#{exclude}\\b"))

  stripped = {}
  flatVars = flat.flatten(vars)
  for key of flatVars
    if !excludePatterns.some((val) => key.match(val))
      # replace attribute, moving "lead." fields up a level
      _.set stripped, key.replace(/^lead\./, ''), flatVars[key]?.valueOf()

  stripped
