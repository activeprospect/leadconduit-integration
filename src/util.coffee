humanname = require 'humanname'

# given a string containing a person's full name, return a two-element array containing firstName and lastName
parseFullname = (fullname) ->
  parsed = humanname.parse(fullname)
  [ parsed.firstName, parsed.lastName ]


module.exports =
  parseFullname: parseFullname
